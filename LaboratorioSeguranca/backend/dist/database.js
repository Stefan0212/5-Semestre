"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pg_1 = require("pg");
const pool = new pg_1.Pool({
    host: "localhost",
    user: "admin",
    password: "senha123",
    database: "aula_db",
    port: 5432,
});
exports.default = pool;
