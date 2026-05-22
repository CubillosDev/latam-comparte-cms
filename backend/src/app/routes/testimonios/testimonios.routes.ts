import { Router } from "express";
import { TestimoniosController } from "../../services/controller/testimonios.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";
import { RoutesApp } from "../../../core/routes";

export class TestimoniosRoutes extends RoutesApp {
  public router: Router;
  private controller: TestimoniosController;

  constructor() {
    super();
    this.router = Router();
    this.controller = new TestimoniosController();
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
