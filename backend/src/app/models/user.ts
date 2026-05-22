import { Schema, model, Document, Types } from "mongoose";

export type Rol = "superadmin" | "admin_pais" | "editor";

export interface IUser {
  nombre: string;
  correo: string;
  password: string;
  rol: Rol;
  pais_asignado: Types.ObjectId | null;
}

interface IUserDocument extends IUser, Document {}

const UserSchema = new Schema<IUserDocument>(
  {
    nombre: { type: String, required: true, trim: true },
    correo: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    rol: { type: String, enum: ["superadmin", "admin_pais", "editor"], required: true },
    pais_asignado: { type: Schema.Types.ObjectId, ref: "Pais", default: null },
  },
  { timestamps: { createdAt: "fecha_creacion", updatedAt: "fecha_actualizacion" } }
);

UserSchema.methods.toJSON = function () {
  const { __v, password, ...data } = this.toObject();
  return data;
};

export const UserModel = model<IUserDocument>("User", UserSchema);
