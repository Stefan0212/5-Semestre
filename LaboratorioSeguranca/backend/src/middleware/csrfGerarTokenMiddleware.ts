import { NextFunction, Request, Response } from "express";
import crypto, { randomBytes } from "crypto";

export const csrfGerarTokenMiddleware = (req: Request, res: Response, next: NextFunction) => {
    let csrfToken = req.cookies.csrfToken;
    if (!csrfToken) {
        csrfToken = randomBytes(32).toString("hex");
        res.cookie("csrfToken", csrfToken, {
            httpOnly: true,
            secure: true,
            sameSite: "strict"
        });
    }

    res.locals.csrfToken = csrfToken;

    next();
};

export const csrfGerarRecuperarTokenMiddleware = csrfGerarTokenMiddleware;
