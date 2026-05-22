import { Router } from "express";
import { SolicitudesController } from "../../services/controller/solicitudes.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";
import { RoutesApp } from "../../../core/routes";

export class SolicitudesRoutes extends RoutesApp {
  public router: Router;
  private controller: SolicitudesController;

  constructor() {
    super();
    this.router = Router();
    this.controller = new SolicitudesController();
    this.setServicesRoutes();
  }

  protected setServicesRoutes(): void {
    // Endpoint público para que visitantes envíen solicitudes (sin auth)
    this.router.post("/publico", (req, res) => this.controller.crearPublica(req, res));

    this.router.get("/", authenticate, requireRole("superadmin", "admin_pais"), (req, res) => this.controller.listar(req, res));
    this.router.get("/:id", authenticate, requireRole("superadmin", "admin_pais"), (req, res) => this.controller.obtener(req, res));
    this.router.patch("/:id/estado", authenticate, requireRole("superadmin", "admin_pais"), (req, res) => this.controller.cambiarEstado(req, res));
    this.router.delete("/:id", authenticate, requireRole("superadmin", "admin_pais"), (req, res) => this.controller.eliminar(req, res));
  }
}
