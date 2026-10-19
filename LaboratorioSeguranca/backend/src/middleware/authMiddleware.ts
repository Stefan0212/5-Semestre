import { Request, Response, NextFunction, RequestHandler } from "express";
import ValidarToken from "../Services/jwtServices";

export function authMiddleware(roles: number[]): RequestHandler;
export function authMiddleware(req: Request, res: Response, next: NextFunction): void | Promise<any>;
export function authMiddleware(reqOrRoles?: any, res?: any, next?: any): any {
    if (Array.isArray(reqOrRoles)) {
        const perfisPermitidos = reqOrRoles;
        return (req: Request, res: Response, next: NextFunction) => {
            const token = req.cookies.token;
            if (!token) {
                res.status(401).json({ success: false, message: "Token não fornecido" });
                return;
            }
            const valid = ValidarToken(token);
            if (!valid) {
                res.status(401).json({ success: false, message: "Token inválido" });
                return;
            }
            (req as any).user = valid;
            res.locals.payload = valid;

            if (perfisPermitidos && !perfisPermitidos.includes(valid.tipo)) {
                res.status(403).json({ success: false, message: "Acesso negado: perfil sem permissão" });
                return;
            }

            next();
        };
    }

    // Chamado diretamente: authMiddleware(req, res, next)
    const req = reqOrRoles as Request;
    const response = res as Response;
    const nextFn = next as NextFunction;

    const token = req?.cookies?.token;
    if (!token) {
        response.status(401).json({ success: false, message: "Token não fornecido" });
        return;
    }
    const valid = ValidarToken(token);
    if (!valid) {
        response.status(401).json({ success: false, message: "Token inválido" });
        return;
    }
    (req as any).user = valid;
    response.locals.payload = valid;
    nextFn();
}
