import { Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { UserModel } from "../../models/user";
import bcrypt from "bcryptjs";

export class UsuariosController {
  async listar(_req: AuthRequest, res: Response): Promise<void> {
    try {
      const usuarios = await UserModel.find()
        .populate("pais_asignado", "nombre codigo")
        .sort({ fecha_creacion: -1 });
      res.status(200).json({ ok: true, usuarios });
    } catch (error) {
      console.error("Error al listar usuarios:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async crear(req: AuthRequest, res: Response): Promise<void> {
    const { nombre, correo, password, rol, pais_asignado } = req.body;

    if (!nombre || !correo || !password || !rol) {
      res.status(400).json({
        ok: false,
        message: "Campos obligatorios: nombre, correo, password, rol",
      });
      return;
    }

    if (!["superadmin", "admin_pais", "editor"].includes(rol)) {
      res.status(400).json({ ok: false, message: "Rol inválido" });
      return;
    }

    try {
      const exists = await UserModel.findOne({ correo: correo.toLowerCase() });
      if (exists) {
        res.status(409).json({ ok: false, message: "El correo ya está en uso" });
        return;
      }

      const hashed = bcrypt.hashSync(password, 10);
      const user = await UserModel.create({
        nombre,
        correo,
        password: hashed,
        rol,
        pais_asignado: pais_asignado || null,
      });
      const populated = await user.populate("pais_asignado", "nombre codigo");
      res.status(201).json({ ok: true, usuario: populated });
    } catch (error) {
      console.error("Error al crear usuario:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async actualizar(req: AuthRequest, res: Response): Promise<void> {
    try {
      const user = await UserModel.findById(req.params.id);
      if (!user) {
        res.status(404).json({ ok: false, message: "Usuario no encontrado" });
        return;
      }

      const { nombre, correo, rol, pais_asignado } = req.body;

      if (correo && correo.toLowerCase() !== user.correo) {
        const exists = await UserModel.findOne({
          correo: correo.toLowerCase(),
          _id: { $ne: req.params.id },
        });
        if (exists) {
          res.status(409).json({ ok: false, message: "El correo ya está en uso" });
          return;
        }
      }

      const updated = await UserModel.findByIdAndUpdate(
        req.params.id,
        { nombre, correo, rol, pais_asignado: pais_asignado || null },
        { new: true, runValidators: true }
      ).populate("pais_asignado", "nombre codigo");

      res.status(200).json({ ok: true, usuario: updated });
    } catch (error) {
      console.error("Error al actualizar usuario:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async eliminar(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (req.params.id === req.user?.id) {
        res.status(400).json({
          ok: false,
          message: "No puedes eliminar tu propio usuario",
        });
        return;
      }

      const user = await UserModel.findById(req.params.id);
      if (!user) {
        res.status(404).json({ ok: false, message: "Usuario no encontrado" });
        return;
      }

      await UserModel.findByIdAndDelete(req.params.id);
      res.status(200).json({ ok: true, message: "Usuario eliminado correctamente" });
    } catch (error) {
      console.error("Error al eliminar usuario:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
