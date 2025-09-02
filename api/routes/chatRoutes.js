import express from "express";
import { getChatRoom, getMessage } from "../controller/chatController";
import authMiddleware from "../middleware/mauthMiddleWare";

const chatRoute = express.Router();

chatRoute.post("/getMessage", authMiddleware, getMessage);
chatRoute.get("/getChatRoom", authMiddleware, getChatRoom);

export default chatRoute;
