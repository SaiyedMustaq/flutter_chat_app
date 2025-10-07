import express from "express";

import {
  registerUser,
  loginUser,
  getAlluserList,
} from "../controller/userController.js";

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/users", getAlluserList);

export default router;
