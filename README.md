# Latinoamérica Comparte — CMS Admin Multipaís

Sistema de administración de contenido (CMS) para la plataforma **Latinoamérica Comparte**. Permite gestionar noticias, testimonios y solicitudes de contacto desde una aplicación móvil Flutter conectada a una API REST con autenticación JWT y filtrado de datos por país.

Proyecto integrador — Ingeniería de Sistemas · USTA Tunja

---

## Stack

| Capa | Tecnología |
|------|-----------|
| App móvil | Flutter 3 + Dart 3 |
| Backend / API | Node.js 18 + Express 5 + TypeScript |
| Base de datos | MongoDB Atlas + Mongoose ODM |
| Autenticación | JWT (jsonwebtoken) + bcryptjs |
| Estado (Flutter) | Provider (ChangeNotifier) |
| HTTP client | Dio con interceptor JWT |
| Almacenamiento local | flutter_secure_storage |

---

## Estructura del repositorio

```
latam-comparte-cms/
├── backend/          # API REST (Node.js + Express + TypeScript)
│   └── src/
│       ├── app/
│       │   ├── models/       # Schemas Mongoose
│       │   ├── routes/       # Rutas por módulo
│       │   ├── services/     # Controladores
│       │   ├── middleware/   # Auth + role guards
│       │   └── helpers/      # JWT utils
│       ├── core/             # ServerApp + RoutesApp base
│       ├── config.ts         # Variables de entorno
│       └── seed.ts           # Datos de prueba
├── frontend/         # App Flutter
│   └── lib/
│       ├── core/             # Colores, tema, enums
│       ├── models/           # Modelos de datos
│       ├── provider/         # ChangeNotifier providers
│       ├── services/         # ApiClient + servicios REST
│       ├── routes/           # Named routes
│       ├── screens/          # Pantallas por dominio
│       └── widgets/          # Componentes reutilizables
├── ADR.md            # Architecture Decision Records
├── DEV_NOTES.md      # Guía de desarrollo y credenciales de prueba
└── ESTADO_PROYECTO.md # Cobertura de requisitos funcionales
```

---

## Requisitos previos

- **Node.js** ≥ 18
- **Flutter SDK** ≥ 3.x
- Cuenta en [MongoDB Atlas](https://www.mongodb.com/atlas) o MongoDB local

---

## Configuración

### Backend

Crea el archivo `backend/.env`:

```env
PORT=3000
MONGO_URI=mongodb+srv://<usuario>:<password>@<cluster>.mongodb.net/latam-comparte?retryWrites=true&w=majority
JWT_SECRET=tu_clave_secreta_larga_y_segura
```

### Frontend

Crea el archivo `frontend/.env`:

```env
BASE_URL=http://localhost:3000
```

> En emulador Android usa `http://10.0.2.2:3000` en lugar de `localhost`.  
> En dispositivo físico usa la IP local de tu máquina.

---

## Levantar el proyecto

```bash
# Terminal 1 — Backend
cd backend
npm install
npm run dev
# → "connected to the database" + "API listen on 3000"

# Terminal 2 — Frontend
cd frontend
flutter pub get
flutter run                  # dispositivo/emulador conectado
flutter run -d chrome        # web
flutter run -d windows       # escritorio Windows
```

### Poblar la base de datos

```bash
cd backend
npx ts-node src/seed.ts
```

Esto limpia todas las colecciones e inserta datos de prueba con los usuarios de la siguiente sección.

---

## Usuarios de prueba

| Rol | Correo | Contraseña | País |
|-----|--------|------------|------|
| superadmin | super@latamcomparte.org | super123 | (global) |
| admin_pais | admin.co@latamcomparte.org | admin123 | Colombia |
| admin_pais | admin.cl@latamcomparte.org | admin123 | Chile |
| admin_pais | admin.ec@latamcomparte.org | admin123 | Ecuador |
| editor | editor.co@latamcomparte.org | editor123 | Colombia |

---

## API — Endpoints

### Auth · `/api/v1/auth`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/login` | No | Login. Devuelve JWT. |
| GET | `/me` | Bearer | Usuario autenticado. |
| PATCH | `/perfil` | Bearer | Actualizar nombre. |
| POST | `/cambiar-password` | Bearer | Cambiar contraseña. |

### Países · `/api/v1/paises`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | superadmin | Lista de países activos. |
| GET | `/dashboard/superadmin` | superadmin | Métricas globales por país. |
| GET | `/dashboard/pais` | admin_pais, editor | Métricas del país asignado. |

### Noticias · `/api/v1/noticias`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Bearer | Lista filtrada por país según JWT. |
| GET | `/:id` | Bearer | Detalle de noticia. |
| POST | `/` | admin_pais, editor | Crear noticia. |
| PUT | `/:id` | admin_pais, editor | Actualizar noticia. |
| PATCH | `/:id/estado` | admin_pais, editor | Cambiar estado. |
| DELETE | `/:id` | admin_pais | Eliminar noticia. |

### Testimonios · `/api/v1/testimonios`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Bearer | Lista filtrada por país. |
| GET | `/:id` | Bearer | Detalle de testimonio. |
| POST | `/` | admin_pais, editor | Crear testimonio. |
| PUT | `/:id` | admin_pais, editor | Actualizar testimonio. |
| PATCH | `/:id/estado` | admin_pais, editor | Cambiar estado. |
| DELETE | `/:id` | admin_pais | Eliminar testimonio. |

### Solicitudes · `/api/v1/solicitudes`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/publico` | No | Formulario público de contacto. |
| GET | `/` | superadmin, admin_pais | Lista filtrada por país. |
| GET | `/:id` | superadmin, admin_pais | Detalle. |
| PATCH | `/:id/estado` | superadmin, admin_pais | Cambiar estado. |
| DELETE | `/:id` | superadmin, admin_pais | Eliminar solicitud. |

### Usuarios · `/api/v1/usuarios`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | superadmin | Listar usuarios. |
| POST | `/` | superadmin | Crear usuario. |
| PUT | `/:id` | superadmin | Actualizar usuario. |
| DELETE | `/:id` | superadmin | Eliminar usuario. |

### Reportes · `/api/v1/reportes`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | superadmin, admin_pais | Estadísticas por estado y país. |

### Upload · `/api/v1/upload`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/` | Bearer | Subir imagen (multipart, máx 5 MB). Devuelve URL pública. |

---

## Roles y permisos

El token JWT contiene `{ id, rol, pais_asignado }`. El backend filtra automáticamente los datos según el rol; el frontend solo muestra lo que recibe.

| Rol | Acceso a datos | Dashboard | Gestión de usuarios |
|-----|---------------|-----------|---------------------|
| `superadmin` | Todos los países | Global con desglose por país | Sí |
| `admin_pais` | Solo su `pais_asignado` | Métricas de su país | No |
| `editor` | Solo su `pais_asignado` | Métricas de su país | No |

---

## Pantallas (Flutter)

| Ruta | Pantalla | Acceso |
|------|----------|--------|
| `/` | Loading / auto-login | Público |
| `/login` | Login | Público |
| `/contacto` | Formulario de contacto | Público |
| `/dashboard` | Dashboard Superadmin | superadmin |
| `/dashboard/pais` | Dashboard Admin País | admin_pais, editor |
| `/portales` | Portales por país | superadmin |
| `/noticias` | Listado de noticias | Todos |
| `/noticias/nuevo` | Crear / editar noticia | admin_pais, editor |
| `/contenido` | Listado de testimonios | Todos |
| `/testimonios/nuevo` | Crear / editar testimonio | admin_pais, editor |
| `/solicitudes` | Listado de solicitudes | Todos |
| `/solicitudes/detalle` | Detalle de solicitud | Todos |
| `/perfil` | Perfil de usuario | Todos |
| `/configuracion` | Cambiar datos y contraseña | Todos |
| `/reportes` | Estadísticas | superadmin, admin_pais |
| `/usuarios` | Gestión de usuarios | superadmin |

---

## Arquitectura de autenticación

```
Flutter login  →  POST /api/v1/auth/login
               ←  { token: "eyJ..." }
               →  guarda en flutter_secure_storage
               →  cada request: Authorization: Bearer <token>
               →  middleware verifica JWT → { id, rol, pais_asignado }
               →  backend filtra datos por país automáticamente
```

Al iniciar la app, `LoadingPage` intenta un auto-login con el token guardado. Si es válido redirige al dashboard correspondiente según el rol; si falla o no existe, redirige a `/login`. El interceptor de Dio detecta respuestas `401` y redirige al login eliminando el token expirado.

---

## Documentación adicional

| Documento | Contenido |
|-----------|-----------|
| [`ADR.md`](ADR.md) | Decisiones de arquitectura (estado, navegación, HTTP client, ODM, JWT) |
| [`ESTADO_PROYECTO.md`](ESTADO_PROYECTO.md) | Cobertura completa de requisitos funcionales y no funcionales |
| [`DEV_NOTES.md`](DEV_NOTES.md) | Guía de desarrollo, flujo de autenticación y notas técnicas |
| [`backend/README.md`](backend/README.md) | Referencia de la API REST y estructura del backend |
| [`frontend/README.md`](frontend/README.md) | Guía del proyecto Flutter y convenciones de código |
