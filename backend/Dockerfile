# ── Etapa base: Node.js 18 con Alpine Linux (ligero) ──
FROM node:18-alpine

# Dependencias de sistema que algunos paquetes npm (bcrypt, etc.) necesitan para compilar
RUN apk add --no-cache python3 make g++

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# PASO 1: Copiar solo los archivos de dependencias
# Esto permite que Docker cachee npm install y no lo repita si el código cambia
COPY package*.json ./
COPY tsconfig.json ./

# PASO 2: Instalar todas las dependencias (incluyendo devDependencies para ts-node-dev)
RUN npm install

# PASO 3: Copiar el resto del código fuente
# (se hace al final para aprovechar el caché de las capas anteriores)
COPY . .

# PASO 4: Generar config.ts a partir de variables de entorno
# El archivo no está en el repositorio (es sensible), se construye aquí
RUN printf 'export const CONFIG = {\n\
    db: process.env.DB_CONNECTION,\n\
    db_test: process.env.DB_CONNECTION_TEST,\n\
    app: {\n\
        port: process.env.PORT\n\
    },\n\
    jwt_key: process.env.JWT_KEY,\n\
};\n' > src/config.ts

# Documentar el puerto que usa la app
EXPOSE 3000

# Iniciar la app en modo desarrollo con ts-node-dev
# --respawn: reinicia si el proceso falla
# --transpile-only: compilación rápida sin verificación de tipos completa
CMD ["npx", "ts-node-dev", "--respawn", "--transpile-only", "src/app/app.ts"]
