const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

// Database setup
const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath);

// Initialize database
db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    // Insert some sample data if table is empty
    db.get("SELECT COUNT(*) as count FROM users", (err, row) => {
        if (row.count === 0) {
            const sampleUsers = [
                { name: 'John Doe', email: 'john@example.com', age: 30 },
                { name: 'Jane Smith', email: 'jane@example.com', age: 25 },
                { name: 'Bob Johnson', email: 'bob@example.com', age: 35 }
            ];
            
            sampleUsers.forEach(user => {
                db.run("INSERT INTO users (name, email, age) VALUES (?, ?, ?)", 
                       [user.name, user.email, user.age]);
            });
            console.log('Sample users inserted');
        }
    });
});

// Routes

// Health check endpoint
app.get('/', (req, res) => {
    res.json({ 
        message: 'API Server is running!',
        endpoints: {
            'GET /': 'This help message',
            'GET /users': 'Get all users',
            'GET /users/:id': 'Get user by ID',
            'POST /users': 'Create new user',
            'PUT /users/:id': 'Update user by ID',
            'DELETE /users/:id': 'Delete user by ID'
        }
    });
});

// GET all users
app.get('/users', (req, res) => {
    db.all("SELECT * FROM users ORDER BY created_at DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({
            message: 'Users retrieved successfully',
            data: rows,
            count: rows.length
        });
    });
});

// GET user by ID
app.get('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    
    if (isNaN(id)) {
        return res.status(400).json({ error: 'Invalid user ID' });
    }
    
    db.get("SELECT * FROM users WHERE id = ?", [id], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        if (row) {
            res.json({
                message: 'User retrieved successfully',
                data: row
            });
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    });
});

// POST create new user
app.post('/users', (req, res) => {
    const { name, email, age } = req.body;
    
    // Validation
    if (!name || !email) {
        return res.status(400).json({ 
            error: 'Name and email are required fields' 
        });
    }
    
    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.status(400).json({ 
            error: 'Invalid email format' 
        });
    }
    
    db.run("INSERT INTO users (name, email, age) VALUES (?, ?, ?)", 
           [name, email, age || null], function(err) {
        if (err) {
            if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
                res.status(409).json({ error: 'Email already exists' });
            } else {
                res.status(500).json({ error: err.message });
            }
            return;
        }
        
        // Get the created user
        db.get("SELECT * FROM users WHERE id = ?", [this.lastID], (err, row) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.status(201).json({
                message: 'User created successfully',
                data: row
            });
        });
    });
});

// PUT update user by ID
app.put('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, email, age } = req.body;
    
    if (isNaN(id)) {
        return res.status(400).json({ error: 'Invalid user ID' });
    }
    
    if (!name || !email) {
        return res.status(400).json({ 
            error: 'Name and email are required fields' 
        });
    }
    
    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.status(400).json({ 
            error: 'Invalid email format' 
        });
    }
    
    db.run("UPDATE users SET name = ?, email = ?, age = ? WHERE id = ?", 
           [name, email, age || null, id], function(err) {
        if (err) {
            if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
                res.status(409).json({ error: 'Email already exists' });
            } else {
                res.status(500).json({ error: err.message });
            }
            return;
        }
        
        if (this.changes === 0) {
            res.status(404).json({ error: 'User not found' });
            return;
        }
        
        // Get the updated user
        db.get("SELECT * FROM users WHERE id = ?", [id], (err, row) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({
                message: 'User updated successfully',
                data: row
            });
        });
    });
});

// DELETE user by ID
app.delete('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    
    if (isNaN(id)) {
        return res.status(400).json({ error: 'Invalid user ID' });
    }
    
    // First check if user exists
    db.get("SELECT * FROM users WHERE id = ?", [id], (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        
        if (!row) {
            res.status(404).json({ error: 'User not found' });
            return;
        }
        
        // Delete the user
        db.run("DELETE FROM users WHERE id = ?", [id], function(err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            
            res.json({
                message: 'User deleted successfully',
                data: row
            });
        });
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Handle 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
    console.log(`Database file: ${dbPath}`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\nShutting down server...');
    db.close((err) => {
        if (err) {
            console.error(err.message);
        }
        console.log('Database connection closed.');
        process.exit(0);
    });
});

module.exports = app;
