import mongoose from "mongoose";
import messageModel from "../model/message.js";
import { getRoomId } from "../utils/chatHelper";
import { User } from "../model/user";

export const createMessage = async (messageData) => {
  try {
    const message = new messageModel({
      chatRoomId: messageData.chatRoomId,
      messageId: messageData.messageId,
      sender: messageData.sender,
      receiver: messageData.receiver,
      message: messageData.message,
      status: messageData.status || "sent",
    });

    await message.save();
    return message;
  } catch (error) {
    throw new Error("Failed to create message");
  }
};

export const getMessages = async (
  currentUserId,
  senderId,
  receiverId,
  page = 1,
  limit = 20
) => {
  const roomId = getRoomId(senderId, receiverId);
  const query = { chatRoomId: roomId };
  try {
    if (currentUserId == receiverId) {
      const undeliveryQuery = {
        chatRoomId: roomId,
        receiver: mongoose.Types.ObjectId(currentUserId),
        sender: mongoose.Types.ObjectId(senderId),
        status: "sent",
      };
      const undeliveryUpdate = await messageModel.updateMany(undeliveryQuery, {
        $set: { status: "delivered" },
      });
      if (undeliveryUpdate.modifiedCount > 0) {
        console.log(
          undeliveryUpdate.modifiedCount + "Message delived successfully"
        );
      }
    }
    const messages = await messageModel.aggregater(
      {
        $match: query,
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $skip: (page - 1) * limit,
      },
      {
        $limit: limit,
      },
      {
        $addField: {
          isMine: {
            $eq: ["$sender", mongoose.Types.ObjectId(currentUserId)],
          },
        },
      }
    );
    return messages.receiver();
  } catch (error) {
    throw new Error("Failed to get messages");
  }
};

export const updateMessageStatus = async (messageId, status) => {
  try {
    const message = await messageModel.findOneAndUpdate(
      { messageId: messageId },
      { status: status },
      { new: true }
    );
    return message;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};
export const getUndeliverMessage = async (userId, partnertId) => {
  try {
    const message = await messageModel
      .find(
        { receiver: userId },
        { sender: partnertId },
        { status: "sent" },
        { new: true }
      )
      .$sort({ createdAt: 1 });
    return message;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};

export const updateUserLastSeen = async (userId, lastSeen) => {
  try {
    const message = await User.findOneAndUpdate(
      { userId: userId },
      { lastSeen: lastSeen },
      { new: true }
    );
    return message;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};

export const marksMessageAsDeliver = async (userId, partnertId) => {
  try {
    const result = await messageModel.updateMany(
      { receiver: Object(userId), sender: Object(partnertId), status: "sent" },
      {
        $set: {
          status: "delivered",
        },
      },
      { new: true }
    );
    return result.modifiedCount;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};
export const marksMessageAsRead = async (userId, partnertId) => {
  try {
    const result = await messageModel.updateMany(
      {
        receiver: Object(userId),
        sender: Object(partnertId),
        status: ["delivered", "sent"],
      },
      {
        $set: {
          status: "read",
        },
      },
      { new: true }
    );
    return result.modifiedCount;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};

export const getUserLastSeen = async (userId) => {
  try {
    const user = User.findById(userId).select("lastSeen");
    if (!user) {
      return null;
    }
    return user.lastSeen ? User.lastSeen.toISOString() : null;
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};

export const getUserOnlineStatus = async (userId) => {
  try {
    const user = User.findById(userId).select("isOnline lastSeen");
    if (!user) {
      return {
        isOnline: false,
        lastSeen: null,
      };
    }
    return {
      isOnline: user.isOnline || false,
      lastSeen: user.lastSeen ? User.lastSeen.toISOString() : null,
    };
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};

export const chatRoom = async (userId) => {
  try {
    const userObjId = new ObjectId(userId);
    const provetChatQuery = {
      $or: [
        {
          sender: userObjId,
        },
        {
          receiver: userObjId,
        },
      ],
    };
    const provateChats = await messageModel.aggregate([
      {
        $match: provetChatQuery,
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $group: {
          _id: {
            $cond: [{ $ne: ["$sender", userObjId] }, "$sender", "$receiver"],
          },
        },
        latestMessageTime: {
          $first: "$createdAt",
        },
        latestMessage: {
          $first: "$message",
        },
        sender: {
          $first: "$sender",
        },
        receiver: {
          $first: "$receiver",
        },
        message: {
          $push: {
            sender: "$sender",
            receiver: "$receiver",
            status: "$status",
          },
        },
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "userDetails",
        },
      },
      {
        $unwind: "$userDetails",
      },
      {
        $project: {
          _id: 0,
          chatTypel: "private",
          messageId: "$latestMessageId",
          userName: "$userDetails.userName",
          lastSeen: "$userDetails.lastSeen",
          userId: "$userDetails._id",
          latestMessageTime: 1,
          latestMessage: 1,
          senderId: 1,
          unreadCount: {
            $size: {
              $filter: {
                input: "$message",
                as: "message",
                cond: {
                  $and: [
                    { $eq: ["$$message.receiver", userObjId] },
                    { $in: ["$$message.status", ["delivered ", "sent"]] },
                  ],
                },
              },
            },
          },
          latestMessageStatus: {
            $cond: [
              { $eq: ["$sender", userObjId] },
              {
                $arrayElemAt: [
                  {
                    $map: {
                      input: {
                        $filter: {
                          input: "$message",
                          as: "msg",
                          cond: { $eq: ["$$meg.sender", userObjId] },
                        },
                      },
                      as: "m",
                      in: "$$m.status",
                    },
                  },
                  0,
                ],
              },
              null,
            ],
          },
        },
      },
    ]);
    return provateChats.$sort((a, b) => {
      return new Date(b.latestMessageTime) - new Date(a.latestMessageTime);
    });
  } catch (error) {
    throw new Error("Failed to update message status");
  }
};
