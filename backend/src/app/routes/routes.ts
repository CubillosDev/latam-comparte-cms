import { Express } from "express";
import { AuthRoutes } from "./auth/auth.routes";
import { PaisesRoutes } from "./paises/paises.routes";
import { NoticiasRoutes } from "./noticias/noticias.routes";
import { TestimoniosRoutes } from "./testimonios/testimonios.routes";
import { SolicitudesRoutes } from "./solicitudes/solicitudes.routes";
import { UploadRoutes } from "./upload/upload.routes";
import { ReportesRoutes } from "./reportes/reportes.routes";
import { UsuariosRoutes } from "./usuarios/usuarios.routes";

export class RoutesApi {
  private _app: Express;

  constructor(app: Express) {
    this._app = app;
    this.initRoutes();
  }

  private initRoutes(): void {
    this._app.use("/api/v1/auth", new AuthRoutes().router);
    this._app.use("/api/v1/paises", new PaisesRoutes().router);
    this._app.use("/api/v1/noticias", new NoticiasRoutes().router);
    this._app.use("/api/v1/testimonios", new TestimoniosRoutes().router);
    this._app.use("/api/v1/solicitudes", new SolicitudesRoutes().router);
    this._app.use("/api/v1/upload", new UploadRoutes().router);
    this._app.use("/api/v1/reportes", new ReportesRoutes().router);
    this._app.use("/api/v1/usuarios", new UsuariosRoutes().router);
  }
}
