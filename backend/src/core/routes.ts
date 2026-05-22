import { Router } from "express";

export abstract class RoutesApp {
    public abstract router: Router;
    protected abstract setServicesRoutes(): void;
}