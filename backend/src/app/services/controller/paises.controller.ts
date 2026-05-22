import { Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { PaisModel } from "../../models/pais";
import { NoticiaModel } from "../../models/noticia";
import { TestimonioModel } from "../../models/testimonio";
import { SolicitudModel } from "../../models/solicitud";

export class PaisesController {
  async listar(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const paises = await PaisModel.find().sort({ nombre: 1 });
      res.status(200).json({ ok: true, paises });
    } catch (error) {
      console.error("Error al listar países:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async dashboard(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const paises = await PaisModel.find({ activo: true }).sort({ nombre: 1 });

      const metrics = await Promise.all(
        paises.map(async (pais) => {
          const [solicitudesPendientes, noticiasActivas, testimoniosPublicados] = await Promise.all([
            SolicitudModel.countDocuments({ pais: pais._id, estado: "pendiente" }),
            NoticiaModel.countDocuments({ pais: pais._id, estado: "publicado" }),
            TestimonioModel.countDocuments({ pais: pais._id, estado: "publicado" }),
          ]);

          return {
            pais: { id: pais._id, nombre: pais.nombre, codigo: pais.codigo },
            solicitudesPendientes,
            noticiasActivas,
            testimoniosPublicados,
          };
        })
      );

      res.status(200).json({ ok: true, metrics });
    } catch (error) {
      console.error("Error en dashboard:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async dashboardPais(req: AuthRequest, res: Response): Promise<void> {
    const paisId = req.user?.pais_asignado;
    if (!paisId) {
      res.status(400).json({ ok: false, message: "Usuario sin país asignado" });
      return;
    }

    try {
      const pais = await PaisModel.findById(paisId);
      if (!pais) {
        res.status(404).json({ ok: false, message: "País no encontrado" });
        return;
      }

      const [solicitudesPendientes, noticiasActivas, testimoniosPublicados, totalSolicitudes] =
        await Promise.all([
          SolicitudModel.countDocuments({ pais: paisId, estado: "pendiente" }),
          NoticiaModel.countDocuments({ pais: paisId, estado: "publicado" }),
          TestimonioModel.countDocuments({ pais: paisId, estado: "publicado" }),
          SolicitudModel.countDocuments({ pais: paisId }),
        ]);

      res.status(200).json({
        ok: true,
        pais: { id: pais._id, nombre: pais.nombre, codigo: pais.codigo },
        metrics: { solicitudesPendientes, noticiasActivas, testimoniosPublicados, totalSolicitudes },
      });
    } catch (error) {
      console.error("Error en dashboard pais:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
