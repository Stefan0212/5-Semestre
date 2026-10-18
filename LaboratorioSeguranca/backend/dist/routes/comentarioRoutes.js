"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const comentarioController_1 = require("../controllers/comentarioController");
const router = (0, express_1.Router)();
router.post("/", comentarioController_1.criarComentario);
router.get("/", comentarioController_1.listarComentarios);
exports.default = router;
