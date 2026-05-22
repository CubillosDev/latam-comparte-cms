import dotenv from "dotenv";
dotenv.config();

export const CONFIG = {
  app: {
    port: process.env.PORT || 3000,
  },
  db: process.env.MONGO_URI || "mongodb://localhost:27017/latam-comparte",
  jwt_key: process.env.JWT_SECRET || "secret_dev_key",
};
