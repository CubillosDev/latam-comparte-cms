import { Router } from "express";
import { authenticate } from "../../middleware/auth.middleware";
import { multerUpload, UploadController } from "../../services/controller/upload.controller";

export class UploadRoutes {
  router = Router();
  private ctrl = new UploadController();

  constructor() {
    this.router.post(
      "/",
      authenticate,
      multerUpload.single("file"),
      (req, res) => this.ctrl.subirImagen(req as any, res)
    );
  }
}
