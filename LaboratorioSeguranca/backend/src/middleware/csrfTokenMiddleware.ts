import { NextFunction, Request, Response } from "express";

export const csrfTokenMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const tokenCookie = req.cookies.csrfToken;
    const tokenHeader = req.headers['x-csrf-token'];
    if (!tokenCookie || !tokenHeader || tokenCookie !== tokenHeader) {
        return res.status(403).json({
            success: false,
            message: "inválido"
        });
    }

    next();
};
