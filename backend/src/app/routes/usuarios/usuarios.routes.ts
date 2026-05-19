import { Router } from "express";
import { UsuariosController } from "../../services/controller/usuarios.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireRole } from "../../middleware/role.middleware";

export class UsuariosRoutes {
  router = Router();
  private ctrl = new UsuariosController();

  constructor() {
    this.router.get("/", authenticate, requireRole("superadmin"), (req, res) =>
      this.ctrl.listar(req as any, res)
    );
    this.router.post("/", authenticate, requireRole("superadmin"), (req, res) =>
      this.ctrl.crear(req as any, res)
    );
    this.router.put("/:id", authenticate, requireRole("superadmin"), (req, res) =>
      this.ctrl.actualizar(req as any, res)
    );
    this.router.delete("/:id", authenticate, requireRole("superadmin"), (req, res) =>
      this.ctrl.eliminar(req as any, res)
    );
  }
}
