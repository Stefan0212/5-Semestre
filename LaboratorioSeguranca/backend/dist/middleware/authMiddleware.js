"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = authMiddleware;
const jwtServices_1 = __importDefault(require("../Services/jwtServices"));
function authMiddleware(reqOrRoles, res, next) {
    if (Array.isArray(reqOrRoles)) {
        const perfisPermitidos = reqOrRoles;
        return (req, res, next) => {
            const token = req.cookies.token;
            if (!token) {
                res.status(401).json({ success: false, message: "Token não fornecido" });
                return;
            }
            const valid = (0, jwtServices_1.default)(token);
            if (!valid) {
                res.status(401).json({ success: false, message: "Token inválido" });
                return;
            }
            req.user = valid;
            res.locals.payload = valid;
            if (perfisPermitidos && !perfisPermitidos.includes(valid.tipo)) {
                res.status(403).json({ success: false, message: "Acesso negado: perfil sem permissão" });
                return;
            }
            next();
        };
    }
    // Chamado diretamente: authMiddleware(req, res, next)
    const req = reqOrRoles;
    const response = res;
    const nextFn = next;
    const token = req?.cookies?.token;
    if (!token) {
        response.status(401).json({ success: false, message: "Token não fornecido" });
        return;
    }
    const valid = (0, jwtServices_1.default)(token);
    if (!valid) {
        response.status(401).json({ success: false, message: "Token inválido" });
        return;
    }
    req.user = valid;
    response.locals.payload = valid;
    nextFn();
}
