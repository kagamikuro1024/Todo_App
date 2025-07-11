const todoSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  task: { type: String, required: true },
  note: { type: String, default: "" },
  complete: { type: Boolean, default: false },
},
{
  timestamps: true,
});