import express, { Request, Response, NextFunction } from "express";
import userRoutes from "./routes/usuarioRoutes";
import commentRoutes from "./routes/comentarioRoutes";
import hackerMalvadao from "./routes/hackerMalvadaoRoutes";
import ValidarToken from "./Services/jwtServices";
import cors from "cors";
import cookieParser from "cookie-parser";

const app = express();

(global as any).segredoJwt = "super_secret_key_123";

app.use(cors({
    origin: "http://localhost:5173", // Restringir a origem para o frontend
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization", "X-CSRF-Token"],
    credentials: true
}));

app.use(express.json());
app.use(cookieParser());
// app.use(express.urlencoded({ extended: true }));

// Proteção CSRF baseada em cabeçalhos (Origin/Referer)
app.use((req: Request, res: Response, next: NextFunction) => {
    if (['POST', 'PUT', 'DELETE', 'PATCH'].includes(req.method)) {
        const origin = req.headers.origin;
        const allowedOrigin = "http://localhost:5173";
        
        // Se a origem estiver presente, ela deve ser a permitida
        if (origin && origin !== allowedOrigin) {
            res.status(403).json({ success: false, message: 'Possível ataque CSRF bloqueado: Origem não permitida' });
            return;
        }
    }
    next();
});

app.use((req: Request, res: Response, next: NextFunction) => {
    if (req.path === '/usuario/login' || req.path === '/usuario/novo-login') {
        return next();
    }
    
    const token = req.cookies.token;
    
    if (!token) {
        res.status(401).json({ success: false, message: 'Token não fornecido' });
        return;
    }
    
    const valid = ValidarToken(token);
    if (!valid) {
        res.status(401).json({ success: false, message: 'Token inválido' });
        return;
    }
    
    (req as any).user = valid;
    res.locals.payload = valid;
    next();
});

app.use("/usuario", userRoutes);
app.use("/comentario", commentRoutes);
app.use("/hacker-malvadao", hackerMalvadao);

app.listen(3001, () => {
    console.log("Servidor Vulnerável rodando na porta 3001");
});