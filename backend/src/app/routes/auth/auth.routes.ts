import { Router } from "express";
import { AuthController } from "../../services/controller/auth.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { RoutesApp } from "../../../core/routes";

export class AuthRoutes extends RoutesApp {
  public router: Router;
  private controller: AuthController;

  constructor() {
    super();
    this.router = Router();
    this.controller = new AuthController();
    this.setServicesRoutes();
  }

  protected setServicesRoutes(): void {
    this.router.post("/login", (req, res) => this.controller.login(req, res));
    this.router.get("/me", authenticate, (req, res) => this.controller.me(req, res));
  }
}
