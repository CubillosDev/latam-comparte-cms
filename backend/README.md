# Latinoamérica Comparte — API REST (Backend)

API REST construida con **Node.js + Express 5 + TypeScript + MongoDB (Mongoose)**. Gestiona autenticación JWT y todos los módulos de contenido del proyecto Latinoamérica Comparte.

## Stack

- **Node.js** + **Express 5**
- **TypeScript** + **ts-node-dev**
- **Mongoose** — ODM para MongoDB
- **JWT** (`jsonwebtoken`) — autenticación sin estado
- **bcryptjs** — hash de contraseñas

## Requisitos

- Node.js ≥ 18
- Cuenta en [MongoDB Atlas](https://www.mongodb.com/atlas) (o MongoDB local)
- Archivo `.env` configurado (ver abajo)

## Configuración

Edita `backend/.env`:

```env
PORT=3000
MONGO_URI=mongodb+srv://<usuario>:<password>@<cluster>.mongodb.net/<dbname>?retryWrites=true&w=majority
JWT_SECRET=tu_clave_secreta_larga_y_segura
```

> El `.env` no se sube al repositorio. Cada desarrollador debe crear el suyo.

## Comandos

```bash
npm install          # instalar dependencias
npm run dev          # servidor con hot-reload (ts-node-dev)
npm run build        # compilar a JS en /dist
npm start            # correr compilado

# Poblar base de datos con datos de prueba:
npx ts-node src/seed.ts
```

## Endpoints

### Auth — `/api/v1/auth`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/login` | No | Login con correo + password. Devuelve JWT. |
| GET | `/me` | Sí | Datos del usuario autenticado. |

### Países — `/api/v1/paises`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Sí | Lista de países activos. |
| GET | `/dashboard/superadmin` | superadmin | Métricas globales por país. |
| GET | `/dashboard/pais` | admin_pais, editor | Métricas del país asignado. |

### Noticias — `/api/v1/noticias`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Sí | Lista filtrada por país (según JWT). |
| POST | `/` | admin_pais, editor | Crear noticia. |
| PATCH | `/:id` | admin_pais, editor | Actualizar noticia. |
| DELETE | `/:id` | admin_pais | Eliminar noticia. |

### Testimonios — `/api/v1/testimonios`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Sí | Lista filtrada por país. |
| POST | `/` | admin_pais, editor | Crear testimonio. |
| PATCH | `/:id` | admin_pais, editor | Actualizar testimonio. |
| DELETE | `/:id` | admin_pais | Eliminar testimonio. |

### Solicitudes — `/api/v1/solicitudes`

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/` | Sí | Lista filtrada por país. |
| POST | `/publico` | No | Formulario público de contacto. |
| PATCH | `/:id/estado` | admin_pais | Cambiar estado de solicitud. |

## Estructura de roles (JWT)

El token JWT contiene `{ id, rol, pais_asignado }`. El middleware aplica filtros automáticamente:

| Rol | Acceso |
|-----|--------|
| `superadmin` | Todo el contenido de todos los países |
| `admin_pais` | Solo contenido de su `pais_asignado` |
| `editor` | Solo lectura y creación en su `pais_asignado` |

## Estructura del código (`src/`)

```
src/
├── config.ts                    # Variables de entorno centralizadas
├── seed.ts                      # Script de datos iniciales
├── core/
│   ├── server.ts                # Interfaz ServerApp
│   └── routes.ts                # Clase base RoutesApp
└── app/
    ├── app.ts                   # Servidor Express principal
    ├── database/mongo/
    │   └── connect.ts           # Conexión Mongoose
    ├── helpers/
    │   └── jwt.ts               # Generación y verificación de tokens
    ├── middleware/
    │   ├── auth.middleware.ts   # Verificar JWT
    │   └── role.middleware.ts   # Verificar rol
    ├── models/                  # Schemas Mongoose
    ├── services/controller/     # Controladores por módulo
    └── routes/                  # Rutas por módulo
```
