import { Schema, model, Document, Types } from "mongoose";

export type EstadoSolicitud = "pendiente" | "gestionada" | "respondida";

export interface ISolicitud {
  nombre: string;
  correo: string;
  telefono: string;
  finalidad: string;
  pais: Types.ObjectId;
  estado: EstadoSolicitud;
  fecha_creacion: Date;
}

interface ISolicitudDocument extends ISolicitud, Document {}

const SolicitudSchema = new Schema<ISolicitudDocument>({
  nombre: { type: String, required: true, trim: true },
  correo: { type: String, required: true, trim: true, lowercase: true },
  telefono: { type: String, required: true, trim: true },
  finalidad: { type: String, required: true, trim: true },
  pais: { type: Schema.Types.ObjectId, ref: "Pais", required: true },
  estado: { type: String, enum: ["pendiente", "gestionada", "respondida"], default: "pendiente" },
  fecha_creacion: { type: Date, default: Date.now },
});

export const SolicitudModel = model<ISolicitudDocument>("SolicitudContacto", SolicitudSchema);
