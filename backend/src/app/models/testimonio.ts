import { Schema, model, Document, Types } from "mongoose";

export type EstadoTestimonio = "borrador" | "publicado" | "despublicado";

export interface ITestimonio {
  nombre: string;
  foto_url: string;
  testimonio: string;
  pais: Types.ObjectId;
  instagram_url?: string;
  facebook_url?: string;
  estado: EstadoTestimonio;
  fecha_creacion: Date;
}

interface ITestimonioDocument extends ITestimonio, Document {}

const TestimonioSchema = new Schema<ITestimonioDocument>({
  nombre: { type: String, required: true, trim: true },
  foto_url: { type: String, required: true, trim: true },
  testimonio: { type: String, required: true },
  pais: { type: Schema.Types.ObjectId, ref: "Pais", required: true },
  instagram_url: { type: String, trim: true },
  facebook_url: { type: String, trim: true },
  estado: { type: String, enum: ["borrador", "publicado", "despublicado"], default: "borrador" },
  fecha_creacion: { type: Date, default: Date.now },
});

export const TestimonioModel = model<ITestimonioDocument>("Testimonio", TestimonioSchema);
