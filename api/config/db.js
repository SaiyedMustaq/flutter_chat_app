import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();
export const connectDB = async () => {
  try {
    await mongoose.connect(
      "mongodb+srv://chatapp:chatapp@chatapp.afihdki.mongodb.net/",
      {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        writeConcern: { w: "majority" },
      }
    );
    console.log("MongoDB connected");
  } catch (error) {
    console.error("MongoDB connection error:", error);
    process.exit(1);
  }
};
