"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.csrfGerarRecuperarTokenMiddleware = exports.csrfGerarTokenMiddleware = void 0;
const crypto_1 = require("crypto");
const csrfGerarTokenMiddleware = (req, res, next) => {
    let csrfToken = req.cookies.csrfToken;
    if (!csrfToken) {
        csrfToken = (0, crypto_1.randomBytes)(32).toString("hex");
        res.cookie("csrfToken", csrfToken, {
            httpOnly: true,
            secure: true,
            sameSite: "strict"
        });
    }
    res.locals.csrfToken = csrfToken;
    next();
};
exports.csrfGerarTokenMiddleware = csrfGerarTokenMiddleware;
exports.csrfGerarRecuperarTokenMiddleware = exports.csrfGerarTokenMiddleware;
