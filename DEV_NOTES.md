# DEV_NOTES — Latinoamérica Comparte CMS

Apuntes de desarrollo: credenciales, estructura, decisiones técnicas y guías rápidas.
**No subir credenciales reales a Git.**

---

## Credenciales de prueba (seed)

Generadas por `npx ts-node src/seed.ts` desde el directorio `backend/`.

| Rol | Correo | Contraseña | País |
|-----|--------|------------|------|
| superadmin | super@latamcomparte.org | super123 | (global) |
| admin_pais | admin.co@latamcomparte.org | admin123 | Colombia |
| admin_pais | admin.cl@latamcomparte.org | admin123 | Chile |
| admin_pais | admin.ec@latamcomparte.org | admin123 | Ecuador |
| editor | editor.co@latamcomparte.org | editor123 | Colombia |

> El seed limpia todas las colecciones antes de insertar. Volver a correrlo reinicia todos los datos.

---

## Variables de entorno

### Backend (`backend/.env`)

```env
PORT=3000
MONGO_URI=mongodb+srv://admin:<password>@<cluster>.mongodb.net/latam-comparte?retryWrites=true&w=majority&appName=latam-comparte
JWT_SECRET=latam_comparte_jwt_2024_secret
```

### Frontend (`frontend/.env`)

```env
BASE_URL=http://localhost:3000
```

> En emulador Android: `BASE_URL=http://10.0.2.2:3000`
> En dispositivo físico: `BASE_URL=http://<IP-local-de-tu-PC>:3000`

---

## Levantar el proyecto

```bash
# Terminal 1 — Backend
cd backend
npm run dev
# → "connected to the database" + "API listen on 3000"

# Terminal 2 — Frontend
cd frontend
flutter run -d chrome        # web
flutter run -d windows       # escritorio
flutter run                  # dispositivo/emulador conectado
```

---

## Base de datos — MongoDB Atlas

- **Cluster:** `latam-comparte`
- **Usuario DB:** `admin`
- **Colecciones:** `paises`, `users`, `noticias`, `testimonios`, `solicitudes`
- **Panel:** https://cloud.mongodb.com

Compass (GUI local): conectar con el mismo `MONGO_URI` del `.env`.

---

## Arquitectura de autenticación

```
Flutter login → POST /api/v1/auth/login
             ← { token: "eyJ..." }
             → guarda en flutter_secure_storage
             → cada request: Authorization: Bearer <token>
             → middleware verifica JWT → { id, rol, pais_asignado }
             → backend filtra datos por país automáticamente
```

### Flujo de inicio (LoadingPage)

1. `tryAutoLogin()` lee token de `flutter_secure_storage`
2. Si existe → llama `GET /api/v1/auth/me`
3. Si válido → redirige según rol:
   - `superadmin` → `/dashboard`
   - `admin_pais` / `editor` → `/dashboard/pais`
4. Si falla → `/login`

---

## Endpoints públicos (sin token)

| Método | Ruta | Uso |
|--------|------|-----|
| POST | `/api/v1/solicitudes/publico` | Formulario de contacto público |

---

## Decisiones técnicas

- **Todo el filtrado por país en el backend** — el JWT incluye `pais_asignado` y los controladores filtran automáticamente. El frontend no hace ningún filtro.
- **`ApiClient` es un singleton** — se inicializa en `main.dart` con `ApiClient.instance.init()` (síncrono). El interceptor de Dio lee el token de `flutter_secure_storage` en cada request.
- **No hay lógica de negocio en Flutter** — cálculo de métricas, totales y estados ocurre en el backend.
- **Formulario de contacto** — usa `SolicitudesService` directamente sin provider, porque no hay lista de estado que gestionar.

---

## Datos de ejemplo insertados por el seed

### Países
- Colombia (CO), Chile (CL), Ecuador (EC)

### Noticias (4)
- "Transformando comunidades en Antioquia" — Colombia, publicado
- "Nuevas alianzas para 2025" — Colombia, borrador
- "Programa Edifica llega a Santiago" — Chile, publicado
- "Red de microempresas en Quito" — Ecuador, publicado

### Testimonios (4)
- Mariana Restrepo — Colombia, publicado
- Juan Pablo Duarte — Colombia, borrador
- Valentina Morales — Chile, publicado
- Diego Espinoza — Ecuador, publicado

### Solicitudes (4)
- Juan Pérez — Colombia, pendiente
- María González — Chile, gestionada
- Ricardo Castillo — Ecuador, pendiente
- Laura Sánchez — Colombia, respondida
