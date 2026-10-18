"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const hackerMalvadaoController_1 = require("../controllers/hackerMalvadaoController");
const router = (0, express_1.Router)();
router.post("/dados-roubados", hackerMalvadaoController_1.recepcionarDadosRoubados);
exports.default = router;
