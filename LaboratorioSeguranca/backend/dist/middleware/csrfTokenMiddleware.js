"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.csrfTokenMiddleware = void 0;
const csrfTokenMiddleware = (req, res, next) => {
    const tokenCookie = req.cookies.csrfToken;
    const tokenHeader = req.headers['x-csrf-token'];
    if (!tokenCookie || !tokenHeader || tokenCookie !== tokenHeader) {
        return res.status(403).json({
            success: false,
            message: "Token CSRF inválido"
        });
    }
    next();
};
exports.csrfTokenMiddleware = csrfTokenMiddleware;
