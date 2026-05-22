import { Router } from "express";
import { NoticiasController } from "../../services/controller/noticias.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";
import { RoutesApp } from "../../../core/routes";

export class NoticiasRoutes extends RoutesApp {
  public router: Router;
  private controller: NoticiasController;

  constructor() {
    super();
    this.router = Router();
    this.controller = new NoticiasController();
    this.setServicesRoutes();
  }

  protected setServicesRoutes(): void {
    this.router.get("/", authenticate, requireRole("superadmin", "admin_pais", "editor"), (req, res) => this.controller.listar(req, res));
    this.router.get("/:id", authenticate, requireRole("superadmin", "admin_pais", "editor"), (req, res) => this.controller.obtener(req, res));
    this.router.post("/", authenticate, requireRole("superadmin", "admin_pais", "editor"), (req, res) => this.controller.crear(req, res));
    this.router.put("/:id", authenticate, requireRole("superadmin", "admin_pais", "editor"), (req, res) => this.controller.actualizar(req, res));
    this.router.patch("/:id/estado", authenticate, requireRole("superadmin", "admin_pais", "editor"), (req, res) => this.controller.cambiarEstado(req, res));
    this.router.delete("/:id", authenticate, requireRole("superadmin", "admin_pais"), (req, res) => this.controller.eliminar(req, res));
  }
}
