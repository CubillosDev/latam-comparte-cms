import { Express } from "express";
import { AuthRoutes } from "./auth/auth.routes";
import { PaisesRoutes } from "./paises/paises.routes";
import { NoticiasRoutes } from "./noticias/noticias.routes";
import { TestimoniosRoutes } from "./testimonios/testimonios.routes";
import { SolicitudesRoutes } from "./solicitudes/solicitudes.routes";

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
  }
}
