import { Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { SolicitudModel } from "../../models/solicitud";
import { NoticiaModel } from "../../models/noticia";
import { TestimonioModel } from "../../models/testimonio";
import { PaisModel } from "../../models/pais";
import { Types } from "mongoose";

export class ReportesController {
  async obtener(req: AuthRequest, res: Response): Promise<void> {
    try {
      const isSuperAdmin = req.user?.rol === "superadmin";
      const paisFilter = isSuperAdmin
        ? {}
        : { pais: new Types.ObjectId(req.user!.pais_asignado as string) };

      const [solicitudesPorEstado, noticiasPorEstado, testimoniosPorEstado] =
        await Promise.all([
          SolicitudModel.aggregate([
            { $match: paisFilter },
            { $group: { _id: "$estado", count: { $sum: 1 } } },
          ]),
          NoticiaModel.aggregate([
            { $match: paisFilter },
            { $group: { _id: "$estado", count: { $sum: 1 } } },
          ]),
          TestimonioModel.aggregate([
            { $match: paisFilter },
            { $group: { _id: "$estado", count: { $sum: 1 } } },
          ]),
        ]);

      const toMap = (arr: { _id: string; count: number }[]) =>
        arr.reduce(
          (acc, e) => ({ ...acc, [e._id]: e.count }),
          {} as Record<string, number>
        );

      const reportes: Record<string, unknown> = {
        solicitudes: toMap(solicitudesPorEstado),
        noticias: toMap(noticiasPorEstado),
        testimonios: toMap(testimoniosPorEstado),
      };

      if (isSuperAdmin) {
        const paises = await PaisModel.find({ activo: true });
        const porPais = await Promise.all(
          paises.map(async (p) => {
            const [sol, not, tes] = await Promise.all([
              SolicitudModel.countDocuments({ pais: p._id }),
              NoticiaModel.countDocuments({ pais: p._id }),
              TestimonioModel.countDocuments({ pais: p._id }),
            ]);
            return {
              pais: p.nombre,
              codigo: p.codigo,
              solicitudes: sol,
              noticias: not,
              testimonios: tes,
            };
          })
        );
        reportes.porPais = porPais;
      }

      res.status(200).json({ ok: true, reportes });
    } catch (error) {
      console.error("Error al obtener reportes:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
