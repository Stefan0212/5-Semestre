import { Router } from "express";
import {
    login,
    atualizarIptu,
    novoLogin,
    getIptuPorIdUsuario,
    getQRCodeOrCodBarras,
    getIptus,
    payloadUsuario
} from "../controllers/usuarioController";
import { authMiddleware } from "../middleware/authMiddleware";
import { csrfTokenMiddleware } from "../middleware/csrfTokenMiddleware";
import { csrfGerarTokenMiddleware as csrfGerarRecuperarTokenMiddleware } from "../middleware/csrfGerarTokenMiddleware";

const router = Router();

router.post("/login", csrfGerarRecuperarTokenMiddleware, login);
router.post("/novo-login", csrfGerarRecuperarTokenMiddleware, novoLogin);
router.post("/atualizar-iptu", csrfTokenMiddleware, authMiddleware([1, 2]), atualizarIptu);
router.put("/atualizar-iptu", csrfTokenMiddleware, authMiddleware([1, 2]), atualizarIptu);
router.get("/iptu-por-usuario", csrfTokenMiddleware, authMiddleware([1, 2]), getIptuPorIdUsuario);
router.post("/iptu-por-usuario", csrfTokenMiddleware, authMiddleware([1, 2]), getIptuPorIdUsuario);
router.get("/payload-usuario", authMiddleware, csrfGerarRecuperarTokenMiddleware, payloadUsuario);
router.get("/codigo-qr-ou-barra", csrfTokenMiddleware, authMiddleware, getQRCodeOrCodBarras);
router.get("/iptus", csrfTokenMiddleware, authMiddleware([1, 2]), getIptus);

export default router;