import { Router } from "express";
import { criarComentario, listarComentarios } from "../controllers/comentarioController";
import { authMiddleware } from "../middleware/authMiddleware";
import { csrfTokenMiddleware } from "../middleware/csrfTokenMiddleware";

const router = Router();

router.post("/", authMiddleware, csrfTokenMiddleware, criarComentario);
router.get("/", authMiddleware, listarComentarios);

export default router;