import { register, login } from "../services/authService.js";

export const registerUser = async (req, res) => {
  try {
    console.log(`Resgiter Body ${req.body}`);
    const { userName, password } = req.body;
    const result = await register(userName, password);
    if (result instanceof Error) {
      return res.status(400).json({ message: result.message });
    }
    return res.status(201).json(result);
  } catch (error) {
    return res.status(500).json({ message: `Internal server error ${error}` });
  }
};

export const loginUser = async (req, res) => {
  try {
    const { userName, password } = req.body;
    const result = await login(userName, password);
    if (result instanceof Error) {
      return res.status(400).json({ message: result.message });
    }
    return res.status(200).json(result);
  } catch (error) {
    return res.status(500).json({ message: "Internal server error" });
  }
};
