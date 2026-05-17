import { Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { TestimonioModel } from "../../models/testimonio";
import { Types } from "mongoose";

export class TestimoniosController {
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

      const testimonios = await TestimonioModel.find(filter)
        .populate("pais", "nombre codigo")
        .sort({ fecha_creacion: -1 });

      res.status(200).json({ ok: true, testimonios });
    } catch (error) {
      console.error("Error al listar testimonios:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async obtener(req: AuthRequest, res: Response): Promise<void> {
    try {
      const testimonio = await TestimonioModel.findById(req.params.id).populate("pais", "nombre codigo");
      if (!testimonio) {
        res.status(404).json({ ok: false, message: "Testimonio no encontrado" });
        return;
      }
      if (!this.canAccessDoc(req, testimonio.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      res.status(200).json({ ok: true, testimonio });
    } catch (error) {
      console.error("Error al obtener testimonio:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async crear(req: AuthRequest, res: Response): Promise<void> {
    const { nombre, foto_url, testimonio, pais, instagram_url, facebook_url, estado } = req.body;

    if (!nombre || !testimonio || !pais) {
      res.status(400).json({ ok: false, message: "Campos obligatorios: nombre, testimonio, pais" });
      return;
    }

    const paisId = req.user?.rol !== "superadmin" ? req.user?.pais_asignado : pais;

    try {
      const nuevo = await TestimonioModel.create({
        nombre, foto_url, testimonio, pais: paisId, instagram_url, facebook_url, estado: estado || "borrador",
      });
      const populated = await nuevo.populate("pais", "nombre codigo");
      res.status(201).json({ ok: true, testimonio: populated });
    } catch (error) {
      console.error("Error al crear testimonio:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async actualizar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const existing = await TestimonioModel.findById(req.params.id);
      if (!existing) {
        res.status(404).json({ ok: false, message: "Testimonio no encontrado" });
        return;
      }
      if (!this.canAccessDoc(req, existing.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }

      const { nombre, foto_url, testimonio, pais, instagram_url, facebook_url, estado } = req.body;
      const paisFinal = req.user?.rol !== "superadmin"
        ? req.user?.pais_asignado
        : (pais ?? existing.pais);
      const updated = await TestimonioModel.findByIdAndUpdate(
        req.params.id,
        { nombre, foto_url, testimonio, pais: paisFinal, instagram_url, facebook_url, estado },
        { new: true, runValidators: true }
      ).populate("pais", "nombre codigo");

      res.status(200).json({ ok: true, testimonio: updated });
    } catch (error) {
      console.error("Error al actualizar testimonio:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async cambiarEstado(req: AuthRequest, res: Response): Promise<void> {
    const { estado } = req.body;
    if (!["borrador", "publicado", "despublicado"].includes(estado)) {
      res.status(400).json({ ok: false, message: "Estado inválido. Valores: borrador, publicado, despublicado" });
      return;
    }

    try {
      const existing = await TestimonioModel.findById(req.params.id);
      if (!existing) {
        res.status(404).json({ ok: false, message: "Testimonio no encontrado" });
        return;
      }
      if (!this.canAccessDoc(req, existing.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }

      existing.estado = estado;
      await existing.save();
      const populated = await existing.populate("pais", "nombre codigo");
      res.status(200).json({ ok: true, testimonio: populated });
    } catch (error) {
      console.error("Error al cambiar estado:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async eliminar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const existing = await TestimonioModel.findById(req.params.id);
      if (!existing) {
        res.status(404).json({ ok: false, message: "Testimonio no encontrado" });
        return;
      }
      if (!this.canAccessDoc(req, existing.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      await TestimonioModel.findByIdAndDelete(req.params.id);
      res.status(200).json({ ok: true, message: "Testimonio eliminado correctamente" });
    } catch (error) {
      console.error("Error al eliminar testimonio:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
