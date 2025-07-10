const mongoose = require("mongoose");
const todoSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  task: { type: String, required: true },
  note: { type: String, default: "" },
  complete: { type: Boolean, default: false },
});
const userSchema = new mongoose.Schema(
  {
    googleId: { type: String, sparse: true, unique: false },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    todos: [todoSchema],
    password: { type: String, required: false },
  },
  {
    timestamps: true,
  }
);
const User = mongoose.model("User", userSchema);
module.exports = User;
