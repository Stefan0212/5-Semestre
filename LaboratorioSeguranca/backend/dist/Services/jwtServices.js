"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = ValidarToken;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
function ValidarToken(token) {
    try {
        const decoded = jsonwebtoken_1.default.verify(token, global.segredoJwt);
        return {
            id: decoded.id,
            tipo: decoded.tipo,
            email: decoded.email,
            nome: decoded.nome
        };
    }
    catch (error) {
        return null;
    }
}
