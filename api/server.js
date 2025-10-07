import express from "express";
import { connectDB } from "./config/db.js";
import userRoutes from "../api/routes/userRoutes.js";
import chatRoute from "../api/routes/chatRoutes.js";
import "dotenv/config"; // Loads .env variables
import Server from "socket.io";
import { createServer } from "http";

import { getRoomId } from "./utils/chatHelper.js";
import {
  createMessage,
  getUndeliverMessage,
  getUserLastSeen,
  marksMessageAsDeliver,
  updateMessageStatus,
  updateUserLastSeen,
} from "./services/chatServices.js";
import { Message } from "./model/message.js";
import { User } from "./model/user.js";

connectDB();
const app = express();
const backEndUrl = process.env.BACKEND_URL;
const port = process.env.PORT;
const version = process.env.VERSION;
app.use(express.json());

app.use(express.urlencoded({ extended: true }));
app.use("/api/users", userRoutes);
app.use("/api/users/chat", chatRoute);

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*",
  },
});
const onlineUser = new Map();
io.on("connection", (socket) => {
  console.log("User connected", socket.id);
  let currentUserId = null;
  ///TODO register event
  socket.on("register_user", ({ userId }) => {
    if (!userId) return;
    currentUserId = userId;
    onlineUser.set(userId, socket.id);
    console.log(`User ${userId} connected with ${socket.id}}`);
    checkPenidingMessage(userId);
  });

  ///TODO Join Room Event
  socket.on("join_room", async ({ userId, partnerId }) => {
    if (!userId || !partnerId) {
      console.log("Invalid user or partner");
      return;
    }
    currentUserId = userId;
    const partnerSocketId = onlineUser.get(partnerId);
    onlineUser.set(userId, socket.id);
    const roomId = getRoomId(userId, partnerId);
    socket.join(roomId);
    console.log(`User ${userId} joined room ${roomId}`);
    try {
      const undeliverdMessage = await getUndeliverMessage(userId, partnerId);
      const undeliverdCount = await marksMessageAsDeliver(userId, partnerId);
      if (undeliverdCount > 0) {
        console.log(`Mark ${undeliverdCount} messages as delivered ${userId} `);

        undeliverdMessage.forEach((message) => {
          io.to(roomId).emit("message+status", {
            messageId: message.messageId,
            status: "delivered",
            sender: message.sender,
            receiver: message.receiver,
          });
        });
      }
      io.to(roomId).emit("user_status", {
        userId: partnerId,
        status: "online",
      });
      if (onlineUser.has(partnerId)) {
        socket.emit("user_status", {
          userId: partnerId,
          status: "online",
        });
      } else {
        const lastSeen = await getUserLastSeen(partnerId);
        socket.emit("user_status", {
          userId: partnerId,
          status: "offline",
          lastSeen: lastSeen || new Date().toISOString(),
        });
      }
    } catch (error) {
      console.log(error);
    }
  });

  ///TODO Send message event
  socket.on("send_message", async (message) => {
    if (
      !message.sender ||
      !message.receiver ||
      !message.message ||
      !message.messageId
    ) {
      console.log("Invalid message");
      return;
    }
    const roomId = getRoomId(message.sender, message.receiver);
    await createMessage({
      ...message,
      status: "sent",
      chatRoomId: roomId,
    });
    console.log(
      `Message in roo ${roomId} sent by ${message.sender} to receive by ${message.receiver} messge is ${message.message}`
    );

    if (onlineUser.has(message.receiver)) {
      message.status = "delivered";
      await updateMessageStatus(message.messageId, "delivered");
    } else {
      message.status = "sent";
    }
    io.to(roomId).emit("new_message", message);

    if (onlineUser.has(message.receiver)) {
      const receiverSocketId = onlineUser.get(message.receiver);
      const receiverSocket = io.sockets.sockets.get(receiverSocketId);
      if (receiverSocket && !receiverSocket.rooms.has(roomId)) {
        const sender = await User.findById(message.sender).select("userName");
        receiverSocket.emit("new_message", {
          ...message,
          senderId: message.sender,
          senderName: sender.userName,
          messageId: message.messageId,
          message: message.message,
        });
      }
    }
  });
  const typingTimer = new Map();
  socket.on(
    "typing_start",
    async ({ userId, receiverId }) => {
      if (!userId && !receiverId) return;
      const roomId = getRoomId(userId, receiverId);
      const key = userId_receiverId;
      if (typingTimer.has(key)) {
        clearTimeout(typingTimer.get(key));
      }
      socket.io(roomId).emit("typing_indicator", {
        userId,
        isTyping: true,
      });
      const timeOut = setTimeout(() => {
        socket.emit("typing_indicator", {
          userId,
          isTyping: false,
        });
      });
      typingTimer.set(key, timeOut);
    },
    5000
  );
  socket.on("typing_end", async ({ userId, receiverId }) => {
    if (!userId && !receiverId) return;
    const roomId = getRoomId(userId, receiverId);
    const key = userId_receiverId;
    if (typingTimer.has(key)) {
      clearTimeout(typingTimer.get(key));
      typingTimer.delete(key);
    }
    socket.io(roomId).emit("typing_indicator", {
      userId,
      isTyping: false,
    });
  });

  socket.on("message_deliverd", async ({ messagId, senderId, receiverId }) => {
    try {
      await updateMessageStatus(messagId, "delivered");
      const roomId = getRoomId(senderId, receiverId);
      const statusUpdate = {
        messageId: messagId,
        status: "delivered",
        sender: senderId,
        receiver: receiverId,
      };
      io.to(roomId).emit("message_status", statusUpdate);
    } catch (error) {}
  });

  socket.on("messages_read", async ({ messagIds, senderId, receiverId }) => {
    try {
      for (const messagId of messagIds) {
        await updateMessageStatus(messagId, "read");
      }

      const roomId = getRoomId(senderId, receiverId);
      messagIds.forEach((messagId) => {
        const statusUpdate = {
          messageId: messagId,
          status: "read",
          sender: senderId,
          receiver: receiverId,
        };
        io.to(roomId).emit("message_status", statusUpdate);
      });
    } catch (error) {}
  });

  socket.on("mark_messages_read", async ({ userId, partnerId }) => {
    try {
      var count = await marksMessageAsRead(userId, partnerId);
      if (count > 0) {
        const roomId = getRoomId(senderId, receiverId);
        io.to(roomId).emit("message_all_read", {
          reader: userId,
          sender: receiverId,
        });
      }
      if (onlineUser.has(partnerId)) {
        const partnerSocketId = onlineUser.get(partnerId);
        const partnerSocket = io.sockets.sockets.get(partnerSocketId);
        if (partnerSocket && !partnerSocket.rooms.has(roomId)) {
          partnerSocket.emit("message_all_read", {
            reader: userId,
            sender: partnerId,
          });
        }
      }
    } catch (error) {}
  });

  socket.on("user_status_change", async ({ userId, status, lastSeen }) => {
    if (status === "offile") {
      await updateUserLastSeen(userId, lastSeen);
      if (onlineUser.get(userId)) {
        onlineUser.delete(userId);
      }
      io.emit("user_status", {
        userId: userId,
        status: "offline",
        lastSeen: lastSeen,
      });
    } else {
      onlineUser.set(userId, socket.id);
      io.emit("user_status", {
        userId: userId,
        status: "online",
      });
    }
  });

  socket.on("disconnect", async () => {
    if (currentUserId) {
      if (onlineUser.has(currentUserId) == socket.id) {
        onlineUser.delete(currentUserId);
      }
      await updateUserLastSeen(currentUserId, new Date().toISOString());
      io.emit("user_status", {
        userId: currentUserId,
        status: "offline",
      });
      console.log(`User ${currentUserId} disconnected`);
    }
  });
});

async function checkPenidingMessage(userId) {
  try {
    const messages = await Message.find({
      receiver: userId,
      status: "sent",
    }).populate("sender", "userName");
    if (messages.length > 0) {
      const messageBySender = {};
      messages.forEach((message) => {
        if (!messageBySender[message.sender._id]) {
          messageBySender[message.sender._id] = [];
        }
        messageBySender[message.sender._id].push(message);
      });

      const userSocke = io.sockets.sockets.get(onlineUser.get(userId));
      if (userSocke) {
        Object.keys(messageBySender).forEach((senderId) => {
          const count = messageBySender[senderId].length;
          const senderName = messageBySender[senderId][0].sender.userName;
          userSocke.emit("pending_message", {
            senderId,
            senderName,
            count,
            latestMessage: messageBySender[senderId][0].message,
          });
        });
      }
    }
  } catch (error) {
    console.log(error);
  }
}
httpServer.listen(process.env.PORT || 3000, function () {
  console.log("Server Starte Mustaq ");
});
