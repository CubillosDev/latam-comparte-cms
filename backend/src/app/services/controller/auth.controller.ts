import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import { UserModel } from "../../models/user";
import { generateToken } from "../../helpers/jwt";
import { AuthRequest } from "../../middleware/auth.middleware";

export class AuthController {
  async login(req: Request, res: Response): Promise<void> {
    const { correo, password } = req.body;

    if (!correo || !password) {
      res.status(400).json({ ok: false, message: "Correo y contraseña son requeridos" });
      return;
    }

    try {
      const user = await UserModel.findOne({ correo }).populate("pais_asignado", "nombre codigo activo");

      if (!user) {
        res.status(401).json({ ok: false, message: "Credenciales inválidas" });
        return;
      }

      const validPassword = bcrypt.compareSync(password, user.password);
      if (!validPassword) {
        res.status(401).json({ ok: false, message: "Credenciales inválidas" });
        return;
      }

      const paisId = user.pais_asignado ? user.pais_asignado._id.toString() : null;
      const token = generateToken(user._id.toString(), user.rol, paisId);

      res.status(200).json({
        ok: true,
        message: "Sesión iniciada correctamente",
        token,
        user: {
          id: user._id,
          nombre: user.nombre,
          correo: user.correo,
          rol: user.rol,
          pais_asignado: user.pais_asignado,
        },
      });
    } catch (error) {
      console.error("Error en login:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }

  async me(req: AuthRequest, res: Response): Promise<void> {
    try {
      const user = await UserModel.findById(req.user?.id).populate("pais_asignado", "nombre codigo activo");

      if (!user) {
        res.status(404).json({ ok: false, message: "Usuario no encontrado" });
        return;
      }

      res.status(200).json({
        ok: true,
        user: {
          id: user._id,
          nombre: user.nombre,
          correo: user.correo,
          rol: user.rol,
          pais_asignado: user.pais_asignado,
        },
      });
    } catch (error) {
      console.error("Error en me:", error);
      res.status(500).json({ ok: false, message: "Error interno del servidor" });
    }
  }
}
