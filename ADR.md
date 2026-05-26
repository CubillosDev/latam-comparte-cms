# ADR — Architecture Decision Record
## CMS Admin Multipaís · Latinoamérica Comparte
### Proyecto Integrador — Facultad de Ingeniería de Sistemas · USTA Tunja

> Documento requerido por **RNF-06** del pliego de requisitos.  
> Versión: 1.0 | Fecha: 2026-05-22

---

## Contexto general

Este documento registra las decisiones técnicas tomadas por el equipo de desarrollo para el proyecto integrador *CMS Admin Móvil — Latinoamérica Comparte*. Para cada decisión se registra: el problema que resuelve, las alternativas consideradas, la opción elegida y la justificación.

---

## ADR-01 — Gestión de estado en Flutter

**Problema:** La aplicación maneja múltiples fuentes de datos asíncronos (auth, noticias, testimonios, solicitudes, países) que deben ser accesibles desde distintas partes del árbol de widgets y reaccionar a cambios del backend.

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| `setState` puro | Cero dependencias | No escala; estado no compartible entre pantallas |
| **Provider (ChangeNotifier)** | Oficial Flutter team, simple, bien documentado | Verboso en proyectos muy grandes |
| Riverpod | Compila-safe, sin BuildContext | Curva de aprendizaje mayor |
| BLoC/Cubit | Separación estricta | Boilerplate excesivo para un semestre |
| GetX | All-in-one | Mezcla capas (estado + navegación + inyección) |

**Decisión:** **Provider con ChangeNotifier**

**Justificación:** El equipo eligió Provider porque es la solución oficial recomendada por el Flutter team para proyectos de complejidad media. Permite separar claramente la capa de estado (providers) de la capa de presentación (widgets) sin introducir boilerplate innecesario. La curva de aprendizaje es la más baja del grupo, lo que permite entregar en un semestre sin deuda técnica de comprensión.

**Consecuencias:** Se creó un provider por módulo (`AuthProvider`, `NoticiasProvider`, `TestimoniosProvider`, `SolicitudesProvider`, `PaisesProvider`), todos registrados en `main.dart` con `MultiProvider`.

---

## ADR-02 — Navegación en Flutter

**Problema:** La aplicación tiene ~12 pantallas con diferentes niveles de acceso por rol. Se necesita un mecanismo que permita navegar entre pantallas y proteger rutas según el estado de autenticación.

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| **Navigator 1.0 (named routes)** | Simple, integrado en Flutter | No soporta deep linking ni URL en web |
| GoRouter | URL-based, guards declarativos | Overhead para proyecto sin deep linking |
| AutoRoute | Code generation | Complejidad innecesaria |
| GetX routing | Integrado con GetX state | Acoplado al ecosistema GetX |

**Decisión:** **Navigator 1.0 con named routes**

**Justificación:** La aplicación es móvil Android sin requisito de deep linking. Named routes declaradas en `routes/routes.dart` son suficientes para gestionar la navegación. La protección de acceso por rol se implementa en `LoadingPage` (redirige según JWT) y en la lógica de cada pantalla. Esta solución es la más fácil de entender y depurar para el equipo.

**Consecuencias:** Todas las rutas están en `routes.dart`. La navegación entre pantallas usa `Navigator.pushNamed()` y `Navigator.pushNamedAndRemoveUntil()` para el flujo de autenticación.

---

## ADR-03 — Cliente HTTP en Flutter

**Problema:** La aplicación hace múltiples llamadas REST al backend. Cada llamada debe incluir el header `Authorization: Bearer <token>`. Se necesita un cliente HTTP que soporte interceptores.

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| `http` (dart) | Librería oficial, liviana | Sin interceptores nativos; requiere wrapper manual |
| **Dio** | Interceptores, timeouts, manejo de errores | Dependencia externa |
| Chopper | Code generation, type-safe | Overhead de generación de código |

**Decisión:** **Dio con interceptor JWT**

**Justificación:** Dio permite definir un `InterceptorsWrapper` que agrega automáticamente `Authorization: Bearer <token>` a cada petición, sin duplicar código en cada servicio. También maneja timeouts (`connectTimeout`, `receiveTimeout`) y errores HTTP de forma consistente. El interceptor lee el token desde `FlutterSecureStorage` en cada request, garantizando que siempre se usa el token más reciente. Se implementó además un interceptor de error 401 que elimina el token expirado y redirige al login.

**Consecuencias:** `ApiClient` es un singleton que inicializa Dio una sola vez en `main.dart`. Todos los servicios (`NoticiasService`, `TestimoniosService`, etc.) obtienen la instancia via `ApiClient.instance.dio`.

---

## ADR-04 — Almacenamiento local seguro del token JWT

**Problema:** El token JWT del usuario debe persistir entre sesiones para el auto-login, pero no debe almacenarse en texto plano (requisito RNF-02 y buenas prácticas de seguridad móvil).

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| `SharedPreferences` | Simple | Texto plano; no encriptado |
| **flutter_secure_storage** | Encriptado (Keychain en iOS, Keystore en Android) | Requiere configuración nativa mínima |
| Hive encriptado | Base de datos local encriptada | Overkill para un solo valor |
| SQLite encriptado | Robusto | Innecesariamente complejo |

**Decisión:** **flutter_secure_storage**

**Justificación:** Es la solución estándar de la industria para almacenar tokens en Flutter. En Android usa el Android Keystore System; en iOS usa el Keychain. El token nunca toca el sistema de archivos en texto plano. La integración con Dio es directa: el interceptor llama `_storage.read(key: 'auth_token')` en cada request.

**Consecuencias:** `ApiClient` encapsula todas las operaciones sobre el token (`getToken`, `saveToken`, `deleteToken`). Ninguna pantalla accede directamente a `FlutterSecureStorage`.

---

## ADR-05 — ODM de MongoDB en el backend

**Problema:** El backend necesita interactuar con MongoDB de forma tipada, con validaciones de schema y población de referencias (países en noticias/testimonios/solicitudes).

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| **Mongoose** | Maduro, TypeScript support, populate() | Abstracción sobre driver nativo |
| MongoDB driver nativo | Control total | Sin schema, validaciones manuales |
| Prisma (experimental MongoDB) | Type-safe, DX moderno | Soporte MongoDB aún limitado/experimental |

**Decisión:** **Mongoose con TypeScript**

**Justificación:** Mongoose ofrece schema validation declarativo (exactamente lo que se muestra en el modelo de datos del PDF), población de referencias (`populate('pais')`) para devolver el objeto país completo en lugar del ObjectId, y tipado TypeScript via `@types/mongoose`. La experiencia del equipo docente con Mongoose también facilita la evaluación del código.

**Consecuencias:** Cada colección tiene su propio archivo en `src/app/models/`. Los schemas definen los tipos, valores por defecto y enums (ej: `estado: { enum: ['borrador', 'publicado'] }`).

---

## ADR-06 — Autenticación JWT en el backend

**Problema:** Se necesita generar tokens JWT firmados al login y verificarlos en cada petición protegida, extrayendo `{ id, rol, pais_asignado }` del payload.

**Alternativas consideradas:**

| Opción | Pros | Contras |
|--------|------|---------|
| **jsonwebtoken** | Estándar Node.js, ampliamente usado | — |
| jose | Estándares modernos (JWK, JWKS) | Complejidad innecesaria para este caso |
| fast-jwt | Más rápido | Menor adopción/documentación |

**Decisión:** **jsonwebtoken**

**Justificación:** `jsonwebtoken` es la librería más utilizada en el ecosistema Node.js para JWT. Firma con `sign()`, verifica con `verify()`, y el payload puede incluir cualquier claim custom (en este caso `{ id, rol, pais_asignado }`). El equipo ya tenía experiencia con ella, reduciendo el riesgo de errores de implementación.

**Consecuencias:** `src/app/helpers/jwt.ts` centraliza `generateToken()` y `verifyToken()`. El middleware `auth.middleware.ts` llama a `verifyToken()` en cada ruta protegida y adjunta el usuario al `req` para uso en los controladores.

---

## ADR-07 — Filtrado de datos por país

**Problema:** Un `admin_pais` no debe poder ver ni modificar datos de otro país. Este filtrado debe aplicarse en todas las operaciones CRUD de noticias, testimonios y solicitudes.

**Decisión:** **Filtrado 100% en el backend, basado en el JWT**

**Justificación:** El filtrado en el frontend sería insuficiente porque cualquier usuario podría manipular las peticiones directamente (ej: con Postman). El backend es la única fuente de verdad. El middleware de autenticación extrae `pais_asignado` del JWT y lo adjunta al request; los controladores usan ese valor para agregar `{ pais: req.user.pais_asignado }` a todas las queries de `admin_pais`. El frontend no implementa ningún filtro propio — simplemente muestra lo que el backend devuelve.

**Consecuencias:** La lógica de negocio de filtrado vive exclusivamente en `src/app/services/controller/`. El frontend (Flutter) solo muestra los datos que recibe, sin lógica condicional de filtrado.

---

## Resumen de decisiones

| ADR | Aspecto | Elección |
|-----|---------|----------|
| ADR-01 | Estado Flutter | Provider (ChangeNotifier) |
| ADR-02 | Navegación Flutter | Navigator 1.0 (named routes) |
| ADR-03 | Cliente HTTP | Dio con interceptor JWT |
| ADR-04 | Almacenamiento local | flutter_secure_storage |
| ADR-05 | ODM MongoDB | Mongoose + TypeScript |
| ADR-06 | JWT backend | jsonwebtoken |
| ADR-07 | Filtrado por país | 100% en backend vía JWT |

---

*Documento elaborado por el equipo de Proyecto Integrador — USTA Tunja.*  
*Líder técnico: Ing. Manuel Leonardo Castro Barinas.*
