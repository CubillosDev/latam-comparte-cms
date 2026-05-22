import mongoose from "mongoose";
import { CONFIG } from "../../../config";

// Establece la conexión con MongoDB usando Mongoose.
// Si la conexión falla, lanza un error para interrumpir el inicio de la aplicación.
export async function dbConnection() {
    try {
        // Permite consultas con campos que no estén definidos en el schema
        mongoose.set("strictQuery", false);
        await mongoose.connect(CONFIG.db, {});
        console.log("connected to the database");
    } catch (error) {
        console.log("error connecting to the database", { error });
        throw new Error("error en la base de datos");
    }
}