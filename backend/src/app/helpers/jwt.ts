import jwt, { JwtPayload } from "jsonwebtoken";
import { CONFIG } from "../../config";

export interface TokenPayload extends JwtPayload {
  id: string;
  rol: string;
  pais_asignado: string | null;
}

export function generateToken(id: string, rol: string, pais_asignado: string | null): string {
  const payload: Omit<TokenPayload, keyof JwtPayload> = { id, rol, pais_asignado };
  return jwt.sign(payload, CONFIG.jwt_key, { expiresIn: "48h" });
}

export function verifyToken(token: string): TokenPayload {
  return jwt.verify(token, CONFIG.jwt_key) as TokenPayload;
}
