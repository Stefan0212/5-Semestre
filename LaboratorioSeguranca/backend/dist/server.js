"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const usuarioRoutes_1 = __importDefault(require("./routes/usuarioRoutes"));
const comentarioRoutes_1 = __importDefault(require("./routes/comentarioRoutes"));
const hackerMalvadaoRoutes_1 = __importDefault(require("./routes/hackerMalvadaoRoutes"));
const jwtServices_1 = __importDefault(require("./Services/jwtServices"));
const cors_1 = __importDefault(require("cors"));
const app = (0, express_1.default)();
global.segredoJwt = "super_secret_key_123";
app.use((0, cors_1.default)({
    origin: "http://localhost:5173", // Restringir a origem para o frontend
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(express_1.default.json());
// app.use(express.urlencoded({ extended: true }));
// Proteção CSRF baseada em cabeçalhos (Origin/Referer)
app.use((req, res, next) => {
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
app.use((req, res, next) => {
    if (req.path === '/usuario/login' || req.path === '/usuario/novo-login') {
        return next();
    }
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        res.status(401).json({ success: false, message: 'Token não fornecido' });
        return;
    }
    const valid = (0, jwtServices_1.default)(token);
    if (!valid) {
        res.status(401).json({ success: false, message: 'Token inválido' });
        return;
    }
    req.user = valid;
    next();
});
app.use("/usuario", usuarioRoutes_1.default);
app.use("/comentario", comentarioRoutes_1.default);
app.use("/hacker-malvadao", hackerMalvadaoRoutes_1.default);
app.listen(3001, () => {
    console.log("Servidor Vulnerável rodando na porta 3001");
});
