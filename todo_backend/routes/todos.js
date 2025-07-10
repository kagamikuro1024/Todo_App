//Routes for handling todo operations
const router = require("express").Router();
const User = require("../models/User");
const jwt = require("jsonwebtoken");
require("dotenv").config();

// Middleware to authenticate JWT
const protect = async (req, res, next) => {
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }
  if (!token) {
    return res.status(401).json({ message: "Not authorized, no token" });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select("-__v");
    next();
  } catch (err) {
    res.status(401).json({ message: "Not authorized, token failed" });
  }
};
//Get all todos for the authenticated user
router.get("/", protect, async (req, res) => {
  try {
    res.json(req.user.todos);
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});
//Add a new todo for the authenticated user
router.post("/", protect, async (req, res) => {
  const { id, task, note, complete } = req.body;
  if (!id || !task) {
    return res.status(400).json({ message: "Please provide id and task" });
  }
  try {
    const newTodo = { id, task, note, complete };
    req.user.todos.push(newTodo);
    await req.user.save();
    res.status(201).json(newTodo); // Trả về object vừa thêm
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});
//Update a todo by id for the authenticated user
router.put("/:todoID", protect, async (req, res) => {
  const { todoID } = req.params;
  const { task, note, complete } = req.body;
  try {
    const todoIndex = req.user.todos.findIndex((todo) => todo.id === todoID);
    if (todoIndex === -1) {
      return res.status(404).json({ message: "Todo not found" });
    }
    if (task != undefined) req.user.todos[todoIndex].task = task;
    if (note != undefined) req.user.todos[todoIndex].note = note;
    if (complete != undefined) req.user.todos[todoIndex].complete = complete;
    await req.user.save();
    res.json(req.user.todos[todoIndex]);
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});
//Delete a todo by id for the authenticated user
router.delete("/:todoID", protect, async (req, res) => {
  const { todoID } = req.params;
  try {
    const originalTodoCount = req.user.todos.length;
    req.user.todos = req.user.todos.filter((todo) => todo.id !== todoID);
    if (req.user.todos.length === originalTodoCount) {
      return res.status(404).json({ message: "Todo not found" });
    }
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
