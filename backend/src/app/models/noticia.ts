import { Schema, model, Document, Types } from "mongoose";

export type EstadoNoticia = "borrador" | "publicado";

export interface INoticia {
  titulo: string;
  resumen: string;
  contenido: string;
  autor: string;
  imagen_url?: string;
  pais: Types.ObjectId;
  estado: EstadoNoticia;
  fecha_creacion: Date;
}

interface INoticiaDocument extends INoticia, Document {}

const NoticiaSchema = new Schema<INoticiaDocument>({
  titulo: { type: String, required: true, trim: true },
  resumen: { type: String, required: true, trim: true },
  contenido: { type: String, required: true },
  autor: { type: String, required: true, trim: true },
  imagen_url: { type: String, trim: true },
  pais: { type: Schema.Types.ObjectId, ref: "Pais", required: true },
  estado: { type: String, enum: ["borrador", "publicado"], default: "borrador" },
  fecha_creacion: { type: Date, default: Date.now },
});

export const NoticiaModel = model<INoticiaDocument>("Noticia", NoticiaSchema);
