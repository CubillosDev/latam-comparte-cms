import { Router } from "express";
import { ReportesController } from "../../services/controller/reportes.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";

export class ReportesRoutes {
  router = Router();
  private ctrl = new ReportesController();

  constructor() {
    this.router.get(
      "/",
      authenticate,
      requireRole("superadmin", "admin_pais"),
      (req, res) => this.ctrl.obtener(req as any, res)
    );
  }
}
