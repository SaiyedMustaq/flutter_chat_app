import express from "express";
import { createServer } from "http";
import { connectDB } from "./config/db.js";
import userRoutes from "../../../../mustaq/flutter_chat_app/api/routes/userRoutes.js";
connectDB();
const app = express();

app.use(express.json());

app.use(express.urlencoded({ extended: true }));
app.use("/api/users", userRoutes);

app.listen(process.env.PORT || 3000, () => {
  console.log(`Server is running on port ${process.env.PORT || 3000}`);
});

