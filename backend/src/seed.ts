import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import { CONFIG } from "./config";
import { PaisModel } from "./app/models/pais";
import { UserModel } from "./app/models/user";
import { NoticiaModel } from "./app/models/noticia";
import { TestimonioModel } from "./app/models/testimonio";
import { SolicitudModel } from "./app/models/solicitud";

async function seed() {
  await mongoose.connect(CONFIG.db);
  console.log("Conectado a MongoDB");

  // Limpiar colecciones
  await Promise.all([
    PaisModel.deleteMany({}),
    UserModel.deleteMany({}),
    NoticiaModel.deleteMany({}),
    TestimonioModel.deleteMany({}),
    SolicitudModel.deleteMany({}),
  ]);
  console.log("Colecciones limpiadas");

  // Crear países
  const [colombia, chile, ecuador] = await PaisModel.insertMany([
    { nombre: "Colombia", codigo: "CO", activo: true },
    { nombre: "Chile", codigo: "CL", activo: true },
    { nombre: "Ecuador", codigo: "EC", activo: true },
  ]);
  console.log("Países creados");

  // Hash de contraseñas
  const salt = bcrypt.genSaltSync(10);
  const hash = (pw: string) => bcrypt.hashSync(pw, salt);

  // Crear usuarios
  await UserModel.insertMany([
    { nombre: "Super Admin", correo: "super@latamcomparte.org", password: hash("super123"), rol: "superadmin", pais_asignado: null },
    { nombre: "Admin Colombia", correo: "admin.co@latamcomparte.org", password: hash("admin123"), rol: "admin_pais", pais_asignado: colombia._id },
    { nombre: "Admin Chile", correo: "admin.cl@latamcomparte.org", password: hash("admin123"), rol: "admin_pais", pais_asignado: chile._id },
    { nombre: "Admin Ecuador", correo: "admin.ec@latamcomparte.org", password: hash("admin123"), rol: "admin_pais", pais_asignado: ecuador._id },
    { nombre: "Editor Colombia", correo: "editor.co@latamcomparte.org", password: hash("editor123"), rol: "editor", pais_asignado: colombia._id },
  ]);
  console.log("Usuarios creados");

  // Crear noticias de ejemplo
  await NoticiaModel.insertMany([
    { titulo: "Transformando comunidades en Antioquia", resumen: "El programa EcoArte integra 50 familias en economía circular.", contenido: "El proyecto EcoArte ha logrado integrar a más de 50 familias en una red de economía circular que genera ingresos dignos y transforma el entorno comunitario de forma sostenible.", autor: "María Castro", pais: colombia._id, estado: "publicado" },
    { titulo: "Nuevas alianzas para 2025", resumen: "Conversaciones avanzadas con tres organizaciones internacionales.", contenido: "Estamos en conversaciones avanzadas con tres organizaciones internacionales para fortalecer el apoyo logístico y operativo en la región andina.", autor: "Juan Delgado", pais: colombia._id, estado: "borrador" },
    { titulo: "Programa Edifica llega a Santiago", resumen: "Emprendedores de La Florida acceden a mentoría gratuita.", contenido: "El Programa Edifica extiende su alcance a La Florida, beneficiando a 120 emprendedores locales con mentoría y financiamiento semilla.", autor: "Ana Torres", pais: chile._id, estado: "publicado" },
    { titulo: "Red de microempresas en Quito", resumen: "12 barrios conectados gracias al Programa Nodus.", contenido: "El Programa Nodus logró conectar a líderes empresariales de 12 barrios de Quito, creando una red de apoyo mutuo y acceso a mercados.", autor: "Carlos Vega", pais: ecuador._id, estado: "publicado" },
  ]);
  console.log("Noticias creadas");

  // Crear testimonios de ejemplo
  await TestimonioModel.insertMany([
    { nombre: "Mariana Restrepo", foto_url: "https://i.pravatar.cc/150?img=1", testimonio: "El apoyo recibido ha transformado la manera en que gestionamos los recursos en nuestra zona. Realmente se siente el cambio en la comunidad.", pais: colombia._id, estado: "publicado" },
    { nombre: "Juan Pablo Duarte", foto_url: "https://i.pravatar.cc/150?img=2", testimonio: "Agradezco enormemente la oportunidad brindada. Los procesos son ahora mucho más claros y transparentes.", pais: colombia._id, estado: "borrador" },
    { nombre: "Valentina Morales", foto_url: "https://i.pravatar.cc/150?img=5", testimonio: "Gracias al programa pude abrir mi emprendimiento de repostería. Hoy tengo 3 empleados y ventas constantes.", pais: chile._id, estado: "publicado" },
    { nombre: "Diego Espinoza", foto_url: "https://i.pravatar.cc/150?img=7", testimonio: "La fundación me dio las herramientas para recuperar mi empresa. Sin su apoyo no habría salido adelante.", pais: ecuador._id, estado: "publicado" },
  ]);
  console.log("Testimonios creados");

  // Crear solicitudes de ejemplo
  await SolicitudModel.insertMany([
    { nombre: "Juan Pérez", correo: "juan.perez@empresa.co", telefono: "+57 310 456 7890", finalidad: "Alianza estratégica", pais: colombia._id, estado: "pendiente" },
    { nombre: "María González", correo: "m.gonzalez@fundacion.cl", telefono: "+56 9 8765 4321", finalidad: "Donación corporativa", pais: chile._id, estado: "gestionada" },
    { nombre: "Ricardo Castillo", correo: "rcastillo@correo.com", telefono: "+593 2 123 4567", finalidad: "Ayuda social comedor", pais: ecuador._id, estado: "pendiente" },
    { nombre: "Laura Sánchez", correo: "laura@empresa.co", telefono: "+57 315 789 0123", finalidad: "Voluntariado", pais: colombia._id, estado: "respondida" },
  ]);
  console.log("Solicitudes creadas");

  console.log("\n✅ Seed completado exitosamente");
  console.log("─────────────────────────────────────");
  console.log("Credenciales de acceso:");
  console.log("  superadmin → super@latamcomparte.org / super123");
  console.log("  admin CO   → admin.co@latamcomparte.org / admin123");
  console.log("  admin CL   → admin.cl@latamcomparte.org / admin123");
  console.log("  admin EC   → admin.ec@latamcomparte.org / admin123");
  console.log("  editor CO  → editor.co@latamcomparte.org / editor123");
  console.log("─────────────────────────────────────\n");

  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error("Error en seed:", err);
  process.exit(1);
});
