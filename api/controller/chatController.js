import { getMessages, chatRoom } from "../services/chatServices.js";

export const getMessage = async (req, res) => {
  const { senderId, receiverId, page, limit } = req.body;

  try {
    const message = await getMessages({
      currentUserId: req.userId,
      senderId,
      receiverId,
      page: parent(page, 10),
      limit: parent(limit, 10),
    });
    return res.status(200).json(message);
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

export const getChatRoom = async (req, res) => {
  console.log("getChatRoom");
  try {
    const message = await chatRoom(req.userId);
    return res.status(200).json(message);
  } catch (error) {
    console.log(`Error 1 ==> ${error}`);
    return res.status(500).json({
      statusCode: 500,
      error: error,
      message: "Somthing Want Wrong",
    });
  }
};
