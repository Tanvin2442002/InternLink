const express = require("express");
const router = express.Router();
const sql = require("../DB/connection");
const supabase = require("../supabaseClient");
const multer = require("multer");

// use memory storage so file.buffer is available
const upload = multer({ storage: multer.memoryStorage() });

