// Contrato base que deben cumplir todas las implementaciones de servidor.
// Garantiza que cualquier servidor tenga métodos para iniciarse y cerrarse.
export interface ServerApp {
    start(): Promise<void>;
    close(): Promise<void>;
}