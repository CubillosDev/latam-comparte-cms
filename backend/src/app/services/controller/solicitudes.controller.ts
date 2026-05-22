import { Request, Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { SolicitudModel } from "../../models/solicitud";
import { Types } from "mongoose";

export class SolicitudesController {
  private getPaisFilter(req: AuthRequest): Record<string, unknown> {
    if (req.user?.rol === "admin_pais") {
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

      const solicitudes = await SolicitudModel.find(filter)
        .populate("pais", "nombre codigo")
        .sort({ fecha_creacion: -1 });

      res.status(200).json({ ok: true, solicitudes });
    } catch (error) {
      console.error("Error al listar solicitudes:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async obtener(req: AuthRequest, res: Response): Promise<void> {
    try {
      const solicitud = await SolicitudModel.findById(req.params.id).populate("pais", "nombre codigo");
      if (!solicitud) {
        res.status(404).json({ ok: false, message: "Solicitud no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, solicitud.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      res.status(200).json({ ok: true, solicitud });
    } catch (error) {
      console.error("Error al obtener solicitud:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  // Endpoint público — sin autenticación
  async crearPublica(req: Request, res: Response): Promise<void> {
    const { nombre, correo, telefono, finalidad, pais } = req.body;

    if (!nombre || !correo || !telefono || !finalidad || !pais) {
      res.status(400).json({ ok: false, message: "Campos obligatorios: nombre, correo, telefono, finalidad, pais" });
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      res.status(400).json({ ok: false, message: "Formato de correo inválido" });
      return;
    }

    try {
      const solicitud = await SolicitudModel.create({ nombre, correo, telefono, finalidad, pais, estado: "pendiente" });
      const populated = await solicitud.populate("pais", "nombre codigo");
      res.status(201).json({ ok: true, message: "Solicitud enviada correctamente", solicitud: populated });
    } catch (error) {
      console.error("Error al crear solicitud:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async cambiarEstado(req: AuthRequest, res: Response): Promise<void> {
    const { estado } = req.body;
    if (!["pendiente", "gestionada", "respondida"].includes(estado)) {
      res.status(400).json({ ok: false, message: "Estado inválido. Valores: pendiente, gestionada, respondida" });
      return;
    }

    try {
      const solicitud = await SolicitudModel.findById(req.params.id);
      if (!solicitud) {
        res.status(404).json({ ok: false, message: "Solicitud no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, solicitud.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }

      solicitud.estado = estado;
      await solicitud.save();
      res.status(200).json({ ok: true, solicitud });
    } catch (error) {
      console.error("Error al cambiar estado:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async eliminar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const solicitud = await SolicitudModel.findById(req.params.id);
      if (!solicitud) {
        res.status(404).json({ ok: false, message: "Solicitud no encontrada" });
        return;
      }
      if (!this.canAccessDoc(req, solicitud.pais)) {
        res.status(403).json({ ok: false, message: "Acceso denegado" });
        return;
      }
      await SolicitudModel.findByIdAndDelete(req.params.id);
      res.status(200).json({ ok: true, message: "Solicitud eliminada correctamente" });
    } catch (error) {
      console.error("Error al eliminar solicitud:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
