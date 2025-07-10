const router = require("express").Router();
const passport = require("passport");
const jwt = require("jsonwebtoken");
require("dotenv").config();
// Middleware to check if user is authenticated
const authCheck = (req, res, next) => {
  if (!req.user) {
    res.status(401).json({ message: "Unauthorized" });
  } else {
    next();
  }
};
// Route to initiate Google authentication
router.get(
  "/google",
  passport.authenticate("google", {
    scope: ["profile", "email"],
  })
);
//Callback route for Google authentication
router.get(
  "/google/callback",
  passport.authenticate("google", {
    failureRedirect: "/auth/failure",
  }),
  (req, res) => {
    // Successful authentication, generate JWT and redirect
    const token = jwt.sign({ id: req.user._id }, process.env.JWT_SECRET, {
      expiresIn: "12h",
    });
    res.redirect(`${process.env.CLIENT_URL}/?token=${token}`);
  }
);
const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User'); // Đảm bảo bạn có model User
console.log("GOOGLE_CLIENT_ID:", process.env.GOOGLE_CLIENT_ID); // Log client ID khi khởi tạo
const oAuth2Client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
// Route when authentication fails
router.post("/google/callback", async (req, res) => {
  try {
    const { accessToken } = req.body;
    console.log("accessToken from frontend:", accessToken); // Log accessToken nhận được
    if (!accessToken) {
      return res.status(400).json({ message: "Missing accessToken" });
    }

    // Xác thực accessToken với Google
    let ticket;
    try {
      ticket = await oAuth2Client.getTokenInfo(accessToken);
      console.log("Google token info:", ticket); // Log thông tin token trả về từ Google
    } catch (err) {
      console.error("Google token validation error:", err); // Log lỗi xác thực Google
      return res.status(401).json({ message: "Invalid Google accessToken" });
    }

    // Lấy thông tin user từ Google UserInfo API
    let userInfo = {};
    try {
      const userInfoRes = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });
      userInfo = await userInfoRes.json();
      console.log("Google user info:", userInfo);
    } catch (err) {
      console.error("Google userinfo fetch error:", err);
    }

    let user = await User.findOne({ googleId: ticket.sub });
    if (!user) {
      user = await User.create({
        googleId: ticket.sub,
        name: userInfo.name || userInfo.email || "No Name", // fallback nếu không có name
        email: userInfo.email || ticket.email,
        avatar: userInfo.picture || "",
      });
    }

    // Tạo JWT
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
      expiresIn: "12h",
    });

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
});
router.get("/failure", (req, res) => {
  res.status(401).json({ message: "Authentication failed" });
});
//Route to get the current authenticated user
router.get("/current_user", authCheck, (req, res) => {
  res.status(200).json({
    id: req.user._id,
    name: req.user.name,
    email: req.user.email,
  });
});
// Route to logout the user
router.get("/logout", (req, res) => {
  req.logout((err) => {
    if (err) {
      return res.status(500).json({ message: "Logout failed" });
    }
    req.session = null; // Clear session
    res.status(200).json({ message: "Logged out successfully" });
  });
}); 

module.exports = router;
