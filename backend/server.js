const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');

// Initialize app and server
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"]
  }
});

const PORT = 3000;
const HOST = "192.168.99.139";

// Setup Multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Database connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'earist_mobilehris'
});
db.connect((err) => {
  if (err) {
    console.error('❌ Database connection failed: ' + err.stack);
    return;
  }
  console.log('✅ Connected to MySQL database');
});

// SOCKET.IO
io.on('connection', (socket) => {
  console.log('🔌 Socket connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('❌ Socket disconnected:', socket.id);
  });
});

// === AUTHENTICATION ===
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ message: 'Username and Password are required' });

  db.query('SELECT * FROM users WHERE username = ?', [username], async (err, results) => {
    if (err) return res.status(500).json({ message: 'Server error' });
    if (results.length === 0) return res.status(401).json({ message: 'Invalid credentials' });

    const user = results[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    delete user.password;

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        f_name: user.f_name,
        l_name: user.l_name,
        role: user.role,
        p_pic: user.p_pic,
      }
    });
  });
});

// === USER PROFILE ===
app.put('/api/users/:id', upload.single('p_pic'), async (req, res) => {
  const { id } = req.params;
  const p_pic = req.file ? req.file.filename : null;

  if (!p_pic) return res.status(400).json({ error: 'No profile picture uploaded' });

  try {
    const [users] = await db.promise().query('SELECT * FROM users WHERE id = ?', [id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });

    await db.promise().query('UPDATE users SET p_pic = ? WHERE id = ?', [p_pic, id]);
    res.json({ message: 'Profile picture updated successfully' });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ error: 'Server error during profile update' });
  }
});

app.get('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await db.promise().query(
      'SELECT id, email, username, role, employee_number, f_name, l_name, p_pic, created_at FROM users WHERE id = ?', [id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'User not found' });

    res.json(rows[0]);
  } catch (error) {
    console.error('User fetch error:', error);
    res.status(500).json({ error: 'Server error during user fetch' });
  }
});

// === LEAVE REQUEST ===
app.post('/api/leave-request', (req, res) => {
  const { employee_id, leave_type, start_date, end_date } = req.body;

  if (!employee_id || !leave_type || !start_date || !end_date) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  const sql = `
    INSERT INTO leave_request (employee_id, leave_type, start_date, end_date, status)
    VALUES (?, ?, ?, ?, 'Pending')
  `;
  db.query(sql, [employee_id, leave_type, start_date, end_date], (err, result) => {
    if (err) {
      console.error('Leave request error:', err);
      return res.status(500).json({ message: 'Server error' });
    }
    res.json({ success: true, id: result.insertId });
  });
});

app.get('/leave_requests', (req, res) => {
  db.query('SELECT * FROM leave_request', (err, results) => {
    if (err) {
      console.error('Fetch leave error:', err);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    res.json(results);
  });
});

app.put('/leave_requests/:id', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!['Pending', 'Approved', 'Rejected'].includes(status)) {
    return res.status(400).json({ error: 'Invalid status value' });
  }

  db.query('SELECT * FROM leave_request WHERE id = ?', [id], (err, leaveRows) => {
    if (err || leaveRows.length === 0) {
      return res.status(404).json({ error: 'Leave request not found' });
    }

    const leave = leaveRows[0];

    db.query('UPDATE leave_request SET status = ? WHERE id = ?', [status, id], (err) => {
      if (err) return res.status(500).json({ error: 'Database error', details: err.message });

      db.query('INSERT INTO notification (user_id, leave_request_id, status) VALUES (?, ?, ?)', [leave.employee_id, id, status], (err, notifResult) => {
        if (err) return res.status(500).json({ error: 'Notification insert error', details: err.message });

        db.query(`SELECT n.*, u.f_name, u.l_name, u.username, u.email, u.role, u.p_pic, l.leave_type, l.start_date, l.end_date
                  FROM notification n
                  JOIN users u ON n.user_id = u.id
                  JOIN leave_request l ON n.leave_request_id = l.id
                  WHERE n.id = ?`, [notifResult.insertId], (err, joinedResult) => {
          if (!err && joinedResult.length > 0) {
            io.emit('db_change', { event: 'leave_status_updated', payload: joinedResult[0] });
          }
          res.json({ success: true, message: 'Leave status updated and notification sent' });
        });
      });
    });
  });
});

app.post('/api/update-leave-status', async (req, res) => {
  const { leave_request_id, status, employee_id } = req.body;

  if (!leave_request_id || !status || !employee_id) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  try {
    const [result] = await db.promise().query(
      'UPDATE leave_request SET status = ? WHERE id = ?', [status, leave_request_id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Leave request not found' });
    }

    // Fetch updated leave request and user details
    const [updatedLeaveRequests] = await db.promise().query(
      'SELECT lr.*, u.f_name, u.l_name FROM leave_request lr JOIN users u ON lr.employee_id = u.id WHERE lr.id = ?', [leave_request_id]
    );

    if (updatedLeaveRequests.length > 0) {
      const updatedData = updatedLeaveRequests[0];
      io.emit('leave_status_updated', updatedData);
      res.json({ success: true, message: 'Leave request status updated and notification sent.', data: updatedData });
    } else {
      // Should not happen if update was successful, but handle defensively
      res.status(500).json({ success: false, message: 'Failed to fetch updated data after status update.' });
    }

  } catch (error) {
    console.error('Leave status update error:', error);
    res.status(500).json({ message: 'Server error updating leave status.' });
  }
});

// Endpoint to get notification history for a specific user
app.get('/api/notifications/user/:userId', async (req, res) => {
  const { userId } = req.params;

  if (!userId) {
    return res.status(400).json({ message: 'User ID is required.' });
  }

  try {
    // Fetch notifications for the specific user, joined with relevant tables
    const query = `
      SELECT
        n.id,
        n.user_id,
        n.leave_request_id,
        lr.status AS status,
        lr.leave_type,
        u.f_name,
        u.l_name,
        n.created_at AS time
      FROM
        notification n
      JOIN
        leave_request lr ON n.leave_request_id = lr.id
      JOIN
        users u ON lr.employee_id = u.id
      WHERE
        n.user_id = ?
      ORDER BY
        n.created_at DESC
    `;
    const [notifications] = await db.promise().query(query, [userId]);

    // Return the fetched notifications
    res.json(notifications);

  } catch (error) {
    console.error('Error fetching user notifications:', error);
    res.status(500).json({ message: 'Server error fetching notifications.' });
  }
});

// START SERVER
server.listen(PORT, HOST, () => {
  console.log(`🚀 Server running on http://${HOST}:${PORT}`);
});
