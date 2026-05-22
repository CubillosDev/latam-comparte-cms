import { Request, Response, NextFunction } from "express";
import { verifyToken } from "../helpers/jwt";

export interface AuthUser {
  id: string;
  rol: string;
  pais_asignado: string | null;
}

export interface AuthRequest extends Request {
  user?: AuthUser;
}

export function authenticate(req: AuthRequest, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith("Bearer ")) {
    res.status(401).json({ ok: false, message: "Token no proporcionado" });
    return;
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = verifyToken(token);
    req.user = {
      id: decoded.id,
      rol: decoded.rol,
      pais_asignado: decoded.pais_asignado,
    };
    next();
  } catch {
    res.status(401).json({ ok: false, message: "Token inválido o expirado" });
  }
}
