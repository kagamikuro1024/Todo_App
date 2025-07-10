const router = require("express").Router();
const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// Đăng ký tài khoản mới
router.post("/register", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "Email và mật khẩu là bắt buộc" });

  try {
    // Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(409).json({ message: "Email đã được sử dụng" });

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Tạo user mới
    const newUser = await User.create({
      email,
      password: hashedPassword,
      name: email.split("@")[0], 
      googleId: null,
      todos: [],
    });

    // Tạo JWT
    const token = jwt.sign({ id: newUser._id }, process.env.JWT_SECRET, {
      expiresIn: "12h",
    });

    res.status(201).json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

// Đăng nhập bằng email & password
router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "Email và mật khẩu là bắt buộc" });

  try {
    const user = await User.findOne({ email });
    if (!user || !user.password)
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });

    // Tạo JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "12h",
    });

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;