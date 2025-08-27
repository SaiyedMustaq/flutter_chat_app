import { User } from "../model/user.js";
import jwt from "jsonwebtoken";
import mongoose from "mongoose";

export const register = async (userName, password) => {
  if (password.length < 8) {
    return Error("Password must be at least 8 characters long");
  }
  if (!userName || !password) {
    throw new Error("Username and password are required");
  }
  try {
    const user = new User({ userName, password });
    await user.save();
    return { userId: user._id, userName: user.userName };
  } catch (error) {
    if (error.code === 11000) {
      return new Error("Username already exists");
    }
    if (error instanceof mongoose.Error.ValidationError) {
      return new Error("Invalid user data");
    }
    return new Error("Failed to register user");
  }
};

export const login = async (userName, password) => {
  if (!userName || !password) {
    throw new Error("Username and password are required");
  }

  try {
    const user = await User.findOne({ userName });
    if (!user) {
      return new Error("User not found");
    }
    const isMatch = await user.comparePassword(password, user.password);
    if (!isMatch) {
      return new Error("Invalid password");
    }
    return {
      token: jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
        expiresIn: "1d",
      }),
    };
  } catch (error) {
    return new Error("Failed to login user");
  }
};
