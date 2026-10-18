"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.listarComentarios = exports.criarComentario = void 0;
const database_1 = __importDefault(require("../database"));
const criarComentario = async (req, res) => {
    const { texto, usuarioId } = req.body;
    const query = `INSERT INTO comentario (texto, usuario_id)
         VALUES ($1, $2)`;
    console.log(`Query Executada: ${query}`);
    try {
        await database_1.default.query(query, [texto, usuarioId]);
        res.status(201).json({
            message: "Comentário criado"
        });
    }
    catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.criarComentario = criarComentario;
const listarComentarios = async (_req, res) => {
    try {
        const result = await database_1.default.query("SELECT * FROM comentario");
        res.json(result.rows);
    }
    catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.listarComentarios = listarComentarios;
