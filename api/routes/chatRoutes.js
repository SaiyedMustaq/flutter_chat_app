import express from "express";

import { getChatRoom, getMessage } from "../controller/chatController.js";
import authMiddleware from "../middleware/mauthMiddleWare.js";
const chatRoute = express.Router();
chatRoute.post("/getMessage", authMiddleware, getMessage);
chatRoute.get("/getChatRoom", authMiddleware, getChatRoom);
export default chatRoute;
