import { Router } from "express";
import { PaisesController } from "../../services/controller/paises.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";
import { RoutesApp } from "../../../core/routes";

export class PaisesRoutes extends RoutesApp {
  public router: Router;
  private controller: PaisesController;

  constructor() {
    super();
    this.router = Router();
    this.controller = new PaisesController();
    this.setServicesRoutes();
  }

  protected setServicesRoutes(): void {
    this.router.get("/", authenticate, requireRole("superadmin"), (req, res) => this.controller.listar(req, res));
    this.router.get("/dashboard", authenticate, requireRole("superadmin"), (req, res) => this.controller.dashboard(req, res));
    this.router.get("/dashboard/pais", authenticate, requireRole("admin_pais", "editor"), (req, res) => this.controller.dashboardPais(req, res));
  }
}
