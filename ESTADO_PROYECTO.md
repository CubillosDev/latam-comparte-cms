# Estado del Proyecto — CMS Admin Multipaís
## Latinoamérica Comparte · Proyecto Integrador USTA Tunja

> Documento generado: 2026-05-22  
> Versión del requisito: 1.0 — Borrador para revisión

---

## 1. Stack tecnológico — Verificación

| Capa | Tecnología requerida | Tecnología usada | Estado |
|------|----------------------|-----------------|--------|
| App móvil | Flutter 3 (Dart) | Flutter 3.x — Dart 3 | ✅ |
| Backend / API | Node.js + Express.js | Node.js 18 + Express 5 + TypeScript | ✅ |
| Base de datos | MongoDB | MongoDB Atlas (M0) + Mongoose ODM | ✅ |
| Auth | JWT | jsonwebtoken + bcryptjs | ✅ |
| Almacenamiento seguro | flutter_secure_storage / similar | flutter_secure_storage | ✅ |
| Cliente HTTP | Dio / http / Chopper | Dio (con interceptor JWT) | ✅ |
| Estado en Flutter | Provider / Riverpod / BLoC… | Provider (ChangeNotifier) | ✅ |
| Diseño visual | Material Design 3 | Material 3 (useMaterial3: true) | ✅ |

---

## 2. Colecciones MongoDB — Verificación del modelo

| Colección | Requerida por PDF | Implementada | Campos completos |
|-----------|-------------------|--------------|-----------------|
| `usuarios` | ✅ | ✅ | nombre, correo, password_hash, rol, pais_asignado |
| `paises` | ✅ | ✅ | nombre, codigo, activo |
| `noticias` | ✅ | ✅ | titulo, resumen, contenido, autor, imagen_url, pais, estado, fecha_creacion |
| `testimonios` | ✅ | ✅ | nombre, foto_url, testimonio, pais, instagram_url, facebook_url, estado, fecha_creacion |
| `solicitudes_contacto` | ✅ | ✅ | nombre, correo, telefono, finalidad, pais, estado, fecha_creacion |

---

## 3. Endpoints Backend — Verificación

### Auth `/api/v1/auth`
| Método | Ruta | Auth | Estado |
|--------|------|------|--------|
| POST | `/login` | No | ✅ Implementado |
| GET | `/me` | Sí | ✅ Implementado |

### Países `/api/v1/paises`
| Método | Ruta | Auth | Estado |
|--------|------|------|--------|
| GET | `/` | superadmin | ✅ Implementado |
| GET | `/dashboard/superadmin` | superadmin | ✅ Implementado |
| GET | `/dashboard/pais` | admin_pais, editor | ✅ Implementado |

### Noticias `/api/v1/noticias`
| Método | Ruta | Auth | Estado |
|--------|------|------|--------|
| GET | `/` | Sí | ✅ Implementado (filtro automático por país) |
| GET | `/:id` | Sí | ✅ Implementado |
| POST | `/` | admin_pais, editor | ✅ Implementado |
| PUT | `/:id` | admin_pais, editor | ✅ Implementado |
| PATCH | `/:id/estado` | admin_pais, editor | ✅ Implementado |
| DELETE | `/:id` | admin_pais | ✅ Implementado |

### Testimonios `/api/v1/testimonios`
| Método | Ruta | Auth | Estado |
|--------|------|------|--------|
| GET | `/` | Sí | ✅ Implementado (filtro automático por país) |
| GET | `/:id` | Sí | ✅ Implementado |
| POST | `/` | admin_pais, editor | ✅ Implementado |
| PUT | `/:id` | admin_pais, editor | ✅ Implementado |
| PATCH | `/:id/estado` | admin_pais, editor | ✅ Implementado |
| DELETE | `/:id` | admin_pais | ✅ Implementado |

### Solicitudes `/api/v1/solicitudes`
| Método | Ruta | Auth | Estado |
|--------|------|------|--------|
| POST | `/publico` | No | ✅ Implementado |
| GET | `/` | superadmin, admin_pais | ✅ Implementado (filtro por país) |
| GET | `/:id` | superadmin, admin_pais | ✅ Implementado |
| PATCH | `/:id/estado` | superadmin, admin_pais | ✅ Implementado |
| DELETE | `/:id` | superadmin, admin_pais | ✅ Implementado |

---

## 4. Pantallas Flutter — Verificación

| Pantalla | Ruta | Requerida | Estado |
|----------|------|-----------|--------|
| Loading / Splash | `/` | Sí | ✅ Implementado |
| Login | `/login` | Sí (RF-01) | ✅ Implementado |
| Dashboard Superadmin | `/dashboard` | Sí (RF-02) | ✅ Implementado |
| Dashboard Admin País | `/dashboard/pais` | Sí (RF-02) | ✅ Implementado |
| Gestión de Países | `/portales` | Sí (RF-03) | ✅ Implementado |
| Solicitudes — Listado | `/solicitudes` | Sí (RF-04) | ✅ Implementado |
| Solicitudes — Detalle | `/solicitudes/detalle` | Sí (RF-04) | ✅ Implementado |
| Testimonios — Listado | `/contenido` | Sí (RF-05) | ✅ Implementado |
| Testimonios — Formulario (crear/editar) | `/testimonios/nuevo` | Sí (RF-05) | ✅ Implementado |
| Noticias — Listado | `/noticias` | Sí (RF-06) | ✅ Implementado |
| Noticias — Formulario (crear/editar) | `/noticias/nuevo` | Sí (RF-06) | ✅ Implementado |
| Contacto Público | `/contacto` | Sí (RF-07) | ✅ Implementado |
| Perfil de Usuario | `/perfil` | Sí (sección 4.2) | ✅ Implementado |

---

## 5. Requisitos Funcionales — Cobertura

### RF-01 — Módulo de Autenticación
| Ítem | Estado |
|------|--------|
| Pantalla login con email + contraseña | ✅ |
| Validar credenciales contra backend → JWT | ✅ |
| Almacenar token de forma segura (flutter_secure_storage) | ✅ |
| Identificar rol y país asignado | ✅ |
| Mostrar error si credenciales incorrectas | ✅ |
| Cerrar sesión desde cualquier pantalla (elimina token) | ✅ |
| Redirigir a login si token expirado (interceptor 401) | ✅ |

### RF-02 — Dashboard adaptado por rol
| Ítem | Estado |
|------|--------|
| Panel con acceso rápido según rol | ✅ |
| Superadmin: métricas globales por país | ✅ |
| Admin/editor: solo datos de su país | ✅ |
| Restricción de acceso a módulos no autorizados | ✅ |

### RF-03 — Gestión de países
| Ítem | Estado |
|------|--------|
| Superadmin lista portales disponibles | ✅ |
| Muestra nombre, país y estado (activo/inactivo) | ✅ |
| No accesible para admin_pais ni editor | ✅ |

### RF-04 — Gestión de solicitudes
| Ítem | Estado |
|------|--------|
| Listar con: nombre, correo, teléfono, finalidad, país, fecha, estado | ✅ |
| Superadmin ve todas; admin_pais solo las de su país | ✅ |
| Filtrar por estado y país | ✅ |
| Ver detalle completo | ✅ |
| Cambiar estado (pendiente → gestionada → respondida) | ✅ |
| Eliminar con confirmación previa | ✅ |

### RF-05 — Gestión de testimonios
| Ítem | Estado |
|------|--------|
| Listar con: nombre, país, estado, fecha | ✅ |
| Indicador borrador / publicado / despublicado | ✅ |
| Crear con campos obligatorios (nombre, foto_url, testimonio, país) | ✅ |
| Crear con campos opcionales (instagram, facebook) | ✅ |
| Editar testimonio existente | ✅ |
| Eliminar con confirmación | ✅ |
| Toggle borrador / publicado / despublicado | ✅ |
| Admin/editor solo gestionan su país | ✅ |

### RF-06 — Gestión de noticias
| Ítem | Estado |
|------|--------|
| Listar con: título, país, autor, fecha, estado | ✅ |
| Crear con campos obligatorios (título, resumen, contenido, país, autor, estado) | ✅ |
| Imagen URL opcional | ✅ |
| Guardar como borrador o publicar directamente | ✅ |
| Editar noticia existente | ✅ |
| Eliminar con confirmación | ✅ |
| Cambiar estado borrador ↔ publicado | ✅ |
| Admin/editor solo gestionan su país | ✅ |

### RF-07 — Formulario de contacto público
| Ítem | Estado |
|------|--------|
| Vista accesible sin login | ✅ |
| Campos: nombre, correo, teléfono, finalidad, país | ✅ |
| Validación de formato de correo | ✅ |
| Registra en backend asociado al país | ✅ |
| Mensaje de confirmación al enviar | ✅ |

---

## 6. Requisitos No Funcionales — Cobertura

| Código | Requisito | Estado |
|--------|-----------|--------|
| RNF-01 | Plataforma Android (Flutter 3, Material Design 3) | ✅ |
| RNF-02 | JWT en flutter_secure_storage, Bearer token en headers | ✅ |
| RNF-03 | Navegación móvil estándar (Drawer + BottomNav), loading indicators | ✅ |
| RNF-04 | Errores de red con mensajes amigables | ✅ |
| RNF-05 | Filtrado por país en backend (JWT) + validación en app | ✅ |
| RNF-06 | ADR presentado (ver ADR.md) | ✅ |

---

## 7. Fases del Plan de Trabajo — Estado

| Fase | Descripción | Estado |
|------|-------------|--------|
| Fase 1 | Auth + Roles + Países (HU-01 a HU-04) | ✅ Completa |
| Fase 2 | Gestión de Noticias (HU-14 a HU-18) | ✅ Completa |
| Fase 3 | Gestión de Testimonios (HU-09 a HU-13) | ✅ Completa |
| Fase 4 | Solicitudes de Contacto (HU-05 a HU-08, HU-19) | ✅ Completa |
| Fase 5 | Dashboard + Filtros por País (HU-02, HU-03) | ✅ Completa |

---

## 8. Datos de prueba (Seed)

Ejecutar desde `backend/`: `npx ts-node src/seed.ts`

| Rol | Correo | Contraseña | País |
|-----|--------|------------|------|
| superadmin | super@latamcomparte.org | super123 | (global) |
| admin_pais | admin.co@latamcomparte.org | admin123 | Colombia |
| admin_pais | admin.cl@latamcomparte.org | admin123 | Chile |
| admin_pais | admin.ec@latamcomparte.org | admin123 | Ecuador |
| editor | editor.co@latamcomparte.org | editor123 | Colombia |

---

## 9. Flujo de demostración (sección 12 del PDF)

Para la presentación final, ejecutar el siguiente flujo:

1. **Login como superadmin** (`super@latamcomparte.org / super123`) → Dashboard global con métricas por país
2. **Gestión de noticias** → Crear nueva noticia para Colombia → Publicar → Aparece en lista con estado verde
3. **Cerrar sesión → Login como admin Chile** (`admin.cl@latamcomparte.org / admin123`) → Solo ve datos de Chile
4. **Solicitudes de Chile** → Ver detalle → Cambiar estado a "Gestionada"
5. **Toggle de testimonio** → Cambiar borrador → publicado
6. **Pantalla pública** → Sin login → Formulario de contacto → Enviar → Mensaje de confirmación

---

## 10. Decisiones técnicas (resumen — ver ADR.md)

| Aspecto | Elección | Justificación breve |
|---------|----------|---------------------|
| Estado Flutter | Provider (ChangeNotifier) | Oficial Flutter, simple, bien documentado |
| Navegación | Named routes (Navigator 1.0) | Simple para proyecto académico, sin deep linking |
| Cliente HTTP | Dio | Interceptores nativos para JWT, manejo robusto de errores |
| Auth storage | flutter_secure_storage | Encriptado en Keychain/Keystore, estándar de seguridad |
| ODM MongoDB | Mongoose | Maduro, tipado con TypeScript, validaciones schema |
| Auth JWT | jsonwebtoken | Librería estándar Node.js, bien mantenida |
