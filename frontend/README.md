# Latinoamérica Comparte — Panel administrativo (Flutter)

Aplicación **Flutter** que implementa el panel administrativo y formularios públicos del proyecto **Latinoamérica Comparte**. Conectada a una API REST con autenticación JWT y MongoDB Atlas como base de datos.

## Stack

- **Flutter** + **Dart 3**
- **Provider** — gestión de estado global
- **Dio** — cliente HTTP con interceptor de token automático
- **flutter_secure_storage** — almacenamiento seguro del JWT
- **flutter_dotenv** — variables de entorno

## Requisitos

- Flutter SDK ≥ 3.x
- Backend corriendo en `http://localhost:3000` (ver `/backend`)
- Archivo `.env` configurado (ver abajo)

## Configuración

Crea o edita `frontend/.env`:

```env
BASE_URL=http://localhost:3000
```

> En emulador Android usar `http://10.0.2.2:3000` en lugar de `localhost`.

## Ejecutar

```bash
flutter pub get
flutter run                  # dispositivo conectado / emulador por defecto
flutter run -d chrome        # web en Chrome
flutter run -d windows       # escritorio Windows
```

## Estructura del código (`lib/`)

| Ruta | Propósito |
|------|-----------|
| `main.dart` | Punto de entrada: inicializa ApiClient, registra providers, lanza `MaterialApp`. |
| `core/app/` | Colores (`AppColors`), tema (`AppTheme`), enums globales (`enums.dart`). |
| `routes/routes.dart` | Mapa de rutas nombradas. |
| `services/` | `ApiClient` (singleton Dio + token), servicios por módulo. |
| `provider/` | `ChangeNotifier` providers: auth, paises, noticias, testimonios, solicitudes. |
| `models/` | Modelos de datos con getters de display. |
| `screens/` | Pantallas por dominio. |
| `widgets/` | Componentes reutilizables. |

## Rutas nombradas

| Ruta | Pantalla | Acceso |
|------|----------|--------|
| `/` | `LoadingPage` — auto-login y redirección | Público |
| `/login` | `LoginPage` | Público |
| `/dashboard` | `DashboardSuperAdminPage` | superadmin |
| `/dashboard/pais` | `DashboardAdminPaisPage` | admin_pais, editor |
| `/portales` | `AllPortalsPage` | superadmin |
| `/solicitudes` | `RequestPage` | todos |
| `/solicitudes/detalle` | `RequestDetailsPage` (args: `SolicitudModel`) | todos |
| `/contenido` | `TestimoniosPage` | todos |
| `/testimonios/nuevo` | `FormularioTestimoniosPage` | admin_pais, editor |
| `/noticias` | `NoticiasPage` | todos |
| `/noticias/nuevo` | `FormularioNoticiasPage` | admin_pais, editor |
| `/contacto` | `ContactPage` | Público |

## Roles y permisos

| Rol | Dashboard | Ve contenido | Crea contenido | Ve todos los países |
|-----|-----------|--------------|----------------|---------------------|
| `superadmin` | Global | Todos | Sí | Sí |
| `admin_pais` | Por país | Su país | Sí | No |
| `editor` | Por país | Su país | Sí | No |

El filtrado por país lo aplica el **backend** según el JWT — el frontend solo muestra lo que recibe.

## Autenticación

- Al iniciar, `LoadingPage` llama a `AuthProvider.tryAutoLogin()`.
- Si hay token guardado en `flutter_secure_storage`, valida contra `/api/v1/auth/me`.
- Redirige a `/dashboard` (superadmin) o `/dashboard/pais` (admin_pais / editor).
- El `ApiClient` inyecta `Authorization: Bearer <token>` en cada request via interceptor.

## Providers

Cada provider expone un `LoadState` (idle / loading / loaded / error):

- `AuthProvider` — login, logout, usuario actual
- `PaisesProvider` — métricas globales y por país
- `NoticiasProvider` — CRUD de noticias
- `TestimoniosProvider` — CRUD de testimonios
- `SolicitudesProvider` — listado y cambio de estado de solicitudes

## Convenciones

1. **Nueva pantalla:** widget en `lib/screens/<dominio>/`, export en `screens.dart`, ruta en `routes.dart`.
2. **Nuevo módulo:** service + provider + model siguiendo el patrón existente.
3. **Sin lógica de negocio en el frontend** — todo el filtrado, validación de roles y cálculo de métricas ocurre en el backend.
4. **Formularios:** validar campos vacíos localmente antes de llamar al provider.
