const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const passport = require('passport');
const cookieSession = require('cookie-session');
const cors = require('cors'); 
require('./config/passport-setup');
const authRoutes = require('./routes/auth');
const todoRoutes = require('./routes/todos');
const authLocalRoutes = require('./routes/auth_local');

dotenv.config();

const app = express();

// Kết nối Database
connectDB();

// Cấu hình CORS
app.use(cors({
  origin: ['http://localhost:3000', 'http://192.168.0.109:3000'],
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
}));

// Middleware để parse JSON body
app.use(express.json());

// Cấu hình cookie-session
app.use(cookieSession({
  maxAge: 24 * 60 * 60 * 1000,
  keys: [process.env.JWT_SECRET],
  sameSite: 'Lax',
  secure: false 
}));

// Khởi tạo passport và session
app.use(passport.initialize());
app.use(passport.session());

// Routes
app.use('/auth', authRoutes);
app.use('/api/todos', todoRoutes);
app.use('/auth/local', authLocalRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT,'0.0.0.0', () => console.log(`Server running on port ${PORT}`));