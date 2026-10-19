import { Request, Response } from "express";
import db from "../database";
import jwt from "jsonwebtoken";



export const login = async (req: Request, res: Response) => {
    const { email, password } = req.body;

    const query =
        `SELECT * FROM usuario WHERE email = $1 AND senha = $2`;

    console.log(`Query Executada: ${query}`);

    const result = await db.query(query, [email, password]);

    if (result.rowCount && result.rowCount > 0) {
        
        const token = jwt.sign(
            { 
                id: result.rows[0].id, 
                tipo: result.rows[0].tipo_usuario_id, 
                email: result.rows[0].email, 
                nome: result.rows[0].nome 
            },
            (global as any).segredoJwt,
            { expiresIn: "2h" }
        );

        res.cookie('token', token, {
            httpOnly: true,
            sameSite: 'strict',
            // secure: true // Em produção (HTTPS) habilitar esta opção
        });

        res.json({
            success: true,
            user: result.rows[0]
        });

    } else {
        res.status(401).json({
            success: false,
            message: "Falha no login"
        });
    }
};


export const novoLogin = async (req: Request, res: Response) => {
    const { email, password, nome } = req.body;

    const queryNomeIpuExiste =
        `SELECT * FROM iptu WHERE nome = $1`;

    console.log(`Query Executada: ${queryNomeIpuExiste}`);

    const iptuResult = await db.query(queryNomeIpuExiste, [nome]);

    if (iptuResult.rowCount && iptuResult.rowCount > 0) {

        const query =
            `INSERT INTO usuario (email, senha, nome, tipo_usuario_id)
             VALUES ($1, $2, $3, 3)`;

        console.log(`Query Executada: ${query}`);

        const result = await db.query(query, [email, password, nome]);

        // SQL Injection
        //Acontece quando o hacker executa SQL em campos de entrada, 
        //Afim de que o sistema execute query SQL no banco de dados - como consultas, alteraçãoes e até delete.
        const queryIdUsuario =
            `SELECT id FROM usuario
             WHERE email = $1 AND senha = $2`;

        console.log(`Query Executada: ${queryIdUsuario}`);

        const resultIdUsuario = await db.query(queryIdUsuario, [email, password]);

        const queryUpdateTabelaIptu =
            `UPDATE iptu
             SET usuario_id = $1
             WHERE nome = $2`;

        console.log(`Query Executada: ${queryUpdateTabelaIptu}`);

        const resultUpdate = await db.query(queryUpdateTabelaIptu, [resultIdUsuario.rows[0].id, nome]);

        if (
            result.rowCount &&
            result.rowCount > 0 &&
            resultUpdate.rowCount &&
            resultUpdate.rowCount > 0
        ) {

            const token = jwt.sign(
                { 
                    id: result.rows[0].id, 
                    tipo: result.rows[0].tipo_usuario_id, 
                    email: result.rows[0].email, 
                    nome: result.rows[0].nome 
                },
                (global as any).segredoJwt,
                { expiresIn: "2h" }
            );

            //HTTP Only, SameSite strict, Essa opção impede que o hacker use javascript para acessar os nossos cookies.
            //Com o secure true, impedimos que cookie sejam enviados via HTTP.
            res.cookie('token', token, {
                httpOnly: true,
                sameSite: 'strict',
                secure: true
            });

            res.json({
                success: true,
                user: result.rows[0]
            });

        } else {
            res.status(401).json({
                success: false,
                message: "Falha no login"
            });
        }

    } else {
        res.status(404).json({
            success: false,
            message: `Nome '${nome}' não encontrado no cadastro de municipes`
        });
    }
};


export const atualizarIptu = async (req: Request, res: Response) => {

    const {
        usuarioId,
        novoValor
    } = req.body;

    const query =
        `UPDATE iptu
         SET valor = $1
         WHERE usuario_id = $2`;

    console.log(`Query Executada: ${query}`);

    try {
        await db.query(query, [novoValor, usuarioId]);

        res.json({
            message: "IPTU atualizado"
        });

    } catch (err: any) {
        res.status(500).json({
            error: err.message
        });
    }
};


export const getIptuPorIdUsuario = async (
    req: Request,
    res: Response
) => {

    const usuarioId =
        req.body?.usuarioId ||
        req.query?.usuarioId ||
        (req as any).user?.id ||
        res.locals.payload?.id;
    const query =
        `SELECT * FROM iptu WHERE usuario_id = $1`;

    console.log(`Query Executada: ${query}`);

    try {

        const result = await db.query(query, [usuarioId]);

        console.log(`Retorno: ${JSON.stringify(result.rows)}`);

        res.json({
            iptu: result.rows
        });

    } catch (err: any) {

        res.status(500).json({
            error: err.message
        });
    }
};


export const getIptus = async (
    req: Request,
    res: Response
) => {

    
    const query = `SELECT * FROM iptu`;

    console.log(`Query Executada: ${query}`);

    try {

        const result = await db.query(query);

        res.json({
            iptu: result.rows
        });

    } catch (err: any) {

        res.status(500).json({
            error: err.message
        });
    }
};


export const getQRCodeOrCodBarras = async (
    req: Request,
    res: Response
) => {

    const tipo = req.query.tipo as string;


    let codigoUrl = "";

    if (tipo === "codigoDeBarras") {

        codigoUrl =
            `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=123456789`;

    } else if (tipo === "qrcode") {

        codigoUrl =
            `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=QRCodeDemo`;
    }

    res.json({
        tipo: tipo,
        url: codigoUrl
    });
};

export const payloadUsuario = async (req: Request, res: Response) => {
    return res.json({
        success: true,
        message: "Payload do usuário obtido com sucesso",
        payload: res.locals.payload || (req as any).user,
        cryptoToken: res.locals.csrfToken
    });
};


