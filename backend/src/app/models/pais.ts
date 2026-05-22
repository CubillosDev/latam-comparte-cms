import { Schema, model, Document } from "mongoose";

export interface IPais {
  nombre: string;
  codigo: string;
  activo: boolean;
}

interface IPaisDocument extends IPais, Document {}

const PaisSchema = new Schema<IPaisDocument>({
  nombre: { type: String, required: true, unique: true, trim: true },
  codigo: { type: String, required: true, unique: true, uppercase: true, trim: true },
  activo: { type: Boolean, default: true },
});

export const PaisModel = model<IPaisDocument>("Pais", PaisSchema);
