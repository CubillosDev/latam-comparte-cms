import { Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { NoticiaModel } from "../../models/noticia";
import { Types } from "mongoose";

export class NoticiasController {
  private getPaisFilter(req: AuthRequest): Record<string, unknown> {
    if (req.user?.rol === "admin_pais" || req.user?.rol === "editor") {
      return { pais: req.user.pais_asignado };
    }
    if (req.query.pais) return { pais: req.query.pais };
    return {};
  }

  private canAccessDoc(req: AuthRequest, docPaisId: Types.ObjectId | unknown): boolean {
    if (req.user?.rol === "superadmin") return true;
    return docPaisId?.toString() === req.user?.pais_asignado;
  }

  async listar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const filter: Record<string, unknown> = this.getPaisFilter(req);
      if (req.query.estado) filter.estado = req.query.estado;

      const noticias = await NoticiaModel.find(filter)
        .populate("pais", "nombre codigo")
        .sort({ fecha_creacion: -1 });

      res.status(200).json({ ok: true, noticias });
    } catch (error) {
      console.error("Error al listar noticias:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async obtener(req: AuthRequest, res: Response): Promise<void> {
    try {
      const noticia = await NoticiaModel.findById(req.params.id).populate("pais", "nombre codigo");
      if (!noticia) {
        res.status(404).json({ ok: false, message: "Noticia no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, noticia.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      res.status(200).json({ ok: true, noticia });
    } catch (error) {
      console.error("Error al obtener noticia:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async crear(req: AuthRequest, res: Response): Promise<void> {
    const { titulo, resumen, contenido, autor, imagen_url, pais, estado } = req.body;

    if (!titulo || !resumen || !contenido || !autor || !pais) {
      res.status(400).json({ ok: false, message: "Campos obligatorios: titulo, resumen, contenido, autor, pais" });
      return;
    }

    const paisId = req.user?.rol !== "superadmin" ? req.user?.pais_asignado : pais;

    try {
      const noticia = await NoticiaModel.create({ titulo, resumen, contenido, autor, imagen_url, pais: paisId, estado: estado || "borrador" });
      const populated = await noticia.populate("pais", "nombre codigo");
      res.status(201).json({ ok: true, noticia: populated });
    } catch (error) {
      console.error("Error al crear noticia:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async actualizar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const noticia = await NoticiaModel.findById(req.params.id);
      if (!noticia) {
        res.status(404).json({ ok: false, message: "Noticia no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, noticia.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }

      const { titulo, resumen, contenido, autor, imagen_url, estado } = req.body;
      const updated = await NoticiaModel.findByIdAndUpdate(
        req.params.id,
        { titulo, resumen, contenido, autor, imagen_url, estado },
        { new: true, runValidators: true }
      ).populate("pais", "nombre codigo");

      res.status(200).json({ ok: true, noticia: updated });
    } catch (error) {
      console.error("Error al actualizar noticia:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async cambiarEstado(req: AuthRequest, res: Response): Promise<void> {
    const { estado } = req.body;
    if (!["borrador", "publicado"].includes(estado)) {
      res.status(400).json({ ok: false, message: "Estado inválido. Valores: borrador, publicado" });
      return;
    }

    try {
      const noticia = await NoticiaModel.findById(req.params.id);
      if (!noticia) {
        res.status(404).json({ ok: false, message: "Noticia no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, noticia.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }

      noticia.estado = estado;
      await noticia.save();
      res.status(200).json({ ok: true, noticia });
    } catch (error) {
      console.error("Error al cambiar estado:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async eliminar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const noticia = await NoticiaModel.findById(req.params.id);
      if (!noticia) {
        res.status(404).json({ ok: false, message: "Noticia no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, noticia.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      await NoticiaModel.findByIdAndDelete(req.params.id);
      res.status(200).json({ ok: true, message: "Noticia eliminada correctamente" });
    } catch (error) {
      console.error("Error al eliminar noticia:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
