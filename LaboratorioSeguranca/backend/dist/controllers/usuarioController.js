"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getQRCodeOrCodBarras = exports.getIptus = exports.getIptuPorIdUsuario = exports.atualizarIptu = exports.novoLogin = exports.login = void 0;
const database_1 = __importDefault(require("../database"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const login = async (req, res) => {
    const { email, password } = req.body;
    const query = `SELECT * FROM usuario WHERE email = $1 AND senha = $2`;
    console.log(`Query Executada: ${query}`);
    const result = await database_1.default.query(query, [email, password]);
    if (result.rowCount && result.rowCount > 0) {
        res.json({
            success: true,
            user: result.rows[0],
            token: jsonwebtoken_1.default.sign({
                id: result.rows[0].id,
                tipo: result.rows[0].tipo_usuario_id,
                email: result.rows[0].email,
                nome: result.rows[0].nome
            }, global.segredoJwt, { expiresIn: "2h" })
        });
    }
    else {
        res.status(401).json({
            success: false,
            message: "Falha no login"
        });
    }
};
exports.login = login;
const novoLogin = async (req, res) => {
    const { email, password, nome } = req.body;
    const queryNomeIpuExiste = `SELECT * FROM iptu WHERE nome = $1`;
    console.log(`Query Executada: ${queryNomeIpuExiste}`);
    const iptuResult = await database_1.default.query(queryNomeIpuExiste, [nome]);
    if (iptuResult.rowCount && iptuResult.rowCount > 0) {
        const query = `INSERT INTO usuario (email, senha, nome, tipo_usuario_id)
             VALUES ($1, $2, $3, 3)`;
        console.log(`Query Executada: ${query}`);
        const result = await database_1.default.query(query, [email, password, nome]);
        const queryIdUsuario = `SELECT id FROM usuario
             WHERE email = $1 AND senha = $2`;
        console.log(`Query Executada: ${queryIdUsuario}`);
        const resultIdUsuario = await database_1.default.query(queryIdUsuario, [email, password]);
        const queryUpdateTabelaIptu = `UPDATE iptu
             SET usuario_id = $1
             WHERE nome = $2`;
        console.log(`Query Executada: ${queryUpdateTabelaIptu}`);
        const resultUpdate = await database_1.default.query(queryUpdateTabelaIptu, [resultIdUsuario.rows[0].id, nome]);
        if (result.rowCount &&
            result.rowCount > 0 &&
            resultUpdate.rowCount &&
            resultUpdate.rowCount > 0) {
            res.json({
                success: true,
                user: result.rows[0],
                token: jsonwebtoken_1.default.sign({
                    id: result.rows[0].id,
                    tipo: result.rows[0].tipo_usuario_id,
                    email: result.rows[0].email,
                    nome: result.rows[0].nome
                }, global.segredoJwt, { expiresIn: "2h" })
            });
        }
        else {
            res.status(401).json({
                success: false,
                message: "Falha no login"
            });
        }
    }
    else {
        res.status(404).json({
            success: false,
            message: `Nome '${nome}' não encontrado no cadastro de municipes`
        });
    }
};
exports.novoLogin = novoLogin;
const atualizarIptu = async (req, res) => {
    const { usuarioId, novoValor } = req.body;
    const query = `UPDATE iptu
         SET valor = $1
         WHERE usuario_id = $2`;
    console.log(`Query Executada: ${query}`);
    try {
        await database_1.default.query(query, [novoValor, usuarioId]);
        res.json({
            message: "IPTU atualizado"
        });
    }
    catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.atualizarIptu = atualizarIptu;
const getIptuPorIdUsuario = async (req, res) => {
    const { usuarioId, } = req.body;
    const query = `SELECT * FROM iptu WHERE usuario_id = $1`;
    console.log(`Query Executada: ${query}`);
    try {
        const result = await database_1.default.query(query, [usuarioId]);
        console.log(`Retorno: ${JSON.stringify(result.rows)}`);
        res.json({
            iptu: result.rows
        });
    }
    catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.getIptuPorIdUsuario = getIptuPorIdUsuario;
const getIptus = async (req, res) => {
    const query = `SELECT * FROM iptu`;
    console.log(`Query Executada: ${query}`);
    try {
        const result = await database_1.default.query(query);
        res.json({
            iptu: result.rows
        });
    }
    catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.getIptus = getIptus;
const getQRCodeOrCodBarras = async (req, res) => {
    const tipo = req.query.tipo;
    let codigoUrl = "";
    if (tipo === "codigoDeBarras") {
        codigoUrl =
            `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=123456789`;
    }
    else if (tipo === "qrcode") {
        codigoUrl =
            `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=QRCodeDemo`;
    }
    res.json({
        tipo: tipo,
        url: codigoUrl
    });
};
exports.getQRCodeOrCodBarras = getQRCodeOrCodBarras;
