import mongoose from "mongoose";

const messageSchema = new mongoose.Schema({
  chatRoomId: {
    type: String,
    required: true,
    index: true,
  },
  messageId: {
    type: String,
    required: true,
    index: true,
    unique: true,
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    unique: true,
    index: true,
    required: true,
  },
  receiver: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    unique: true,
    index: true,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ["sent", "delivered", "read"],
    default: "sent",
    index: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
});

messageSchema.index({ chatRoomId: 1, createdAt: -1 });
messageSchema.index({ receiver: 1, status: 1 });

export const Message = mongoose.model("Message", messageSchema);
