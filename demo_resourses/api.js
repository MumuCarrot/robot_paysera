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
    // Drop existing table if it exists to ensure correct schema
    db.run(`DROP TABLE IF EXISTS users`);
    
    db.run(`CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        address TEXT,
        profile TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
    
    // Insert some sample data if table is empty
    db.get("SELECT COUNT(*) as count FROM users", (err, row) => {
        if (row.count === 0) {
            const sampleUsers = [
                { 
                    name: 'John Doe', 
                    email: 'john@example.com', 
                    age: 30,
                    address: JSON.stringify({
                        street: '123 Sample St',
                        city: 'Sample City',
                        state: 'SC',
                        zip_code: '12345',
                        country: 'USA'
                    }),
                    profile: JSON.stringify({
                        occupation: 'Sample Worker',
                        company: 'Sample Corp',
                        phone: '+1-555-000-0001',
                        preferences: {
                            newsletter: true,
                            notifications: false,
                            theme: 'dark'
                        }
                    })
                },
                { 
                    name: 'Jane Smith', 
                    email: 'jane@example.com', 
                    age: 25,
                    address: JSON.stringify({
                        street: '456 Demo Ave',
                        city: 'Demo City',
                        state: 'DC',
                        zip_code: '67890',
                        country: 'USA'
                    }),
                    profile: JSON.stringify({
                        occupation: 'Demo Designer',
                        company: 'Demo Inc',
                        phone: '+1-555-000-0002',
                        preferences: {
                            newsletter: false,
                            notifications: true,
                            theme: 'light'
                        }
                    })
                },
                { 
                    name: 'Bob Johnson', 
                    email: 'bob@example.com', 
                    age: 35,
                    address: JSON.stringify({
                        street: '789 Test Blvd',
                        city: 'Test City',
                        state: 'TC',
                        zip_code: '54321',
                        country: 'USA'
                    }),
                    profile: JSON.stringify({
                        occupation: 'Test Manager',
                        company: 'Test Ltd',
                        phone: '+1-555-000-0003',
                        preferences: {
                            newsletter: true,
                            notifications: true,
                            theme: 'auto'
                        }
                    })
                }
            ];
            
            sampleUsers.forEach(user => {
                db.run("INSERT INTO users (name, email, age, address, profile) VALUES (?, ?, ?, ?, ?)", 
                       [user.name, user.email, user.age, user.address, user.profile]);
            });
            console.log('Sample users with nested data inserted');
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

// Helper function to parse user data
function parseUserData(row) {
    const user = { ...row };
    if (user.address) {
        try {
            user.address = JSON.parse(user.address);
        } catch (e) {
            user.address = null;
        }
    }
    if (user.profile) {
        try {
            user.profile = JSON.parse(user.profile);
        } catch (e) {
            user.profile = null;
        }
    }
    return user;
}

// GET all users
app.get('/users', (req, res) => {
    db.all("SELECT * FROM users ORDER BY created_at DESC", (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        const users = rows.map(parseUserData);
        res.json({
            message: 'Users retrieved successfully',
            data: users,
            count: users.length
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
            const user = parseUserData(row);
            res.json({
                message: 'User retrieved successfully',
                data: user
            });
        } else {
            res.status(404).json({ error: 'User not found' });
        }
    });
});

// Validation helper functions
function validateAddress(address) {
    if (!address) return null;
    if (typeof address !== 'object') {
        return 'Address must be an object';
    }
    if (!address.street || !address.city) {
        return 'Address must contain at least street and city';
    }
    if (address.street.trim() === '') {
        return 'Street cannot be empty';
    }
    return null;
}

function validateProfile(profile) {
    if (!profile) return null;
    if (typeof profile !== 'object') {
        return 'Profile must be an object';
    }
    if (!profile.occupation) {
        return 'Profile must contain occupation';
    }
    if (profile.occupation.trim() === '') {
        return 'Occupation cannot be empty';
    }
    if (profile.phone && !profile.phone.match(/^\+?[\d\s\-\(\)]+$/)) {
        return 'Invalid phone number format';
    }
    if (profile.preferences) {
        if (typeof profile.preferences !== 'object') {
            return 'Preferences must be an object';
        }
        if (profile.preferences.newsletter !== undefined && typeof profile.preferences.newsletter !== 'boolean') {
            return 'Newsletter preference must be boolean';
        }
        if (profile.preferences.notifications !== undefined && typeof profile.preferences.notifications !== 'boolean') {
            return 'Notifications preference must be boolean';
        }
        if (profile.preferences.theme && !['light', 'dark', 'auto'].includes(profile.preferences.theme)) {
            return 'Theme must be one of: light, dark, auto';
        }
    }
    return null;
}

// POST create new user
app.post('/users', (req, res) => {
    const { name, email, age, address, profile } = req.body;
    
    // Basic validation
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
    
    // Nested fields validation
    const addressError = validateAddress(address);
    if (addressError) {
        return res.status(400).json({ error: addressError });
    }
    
    const profileError = validateProfile(profile);
    if (profileError) {
        return res.status(400).json({ error: profileError });
    }
    
    const addressJson = address ? JSON.stringify(address) : null;
    const profileJson = profile ? JSON.stringify(profile) : null;
    
    db.run("INSERT INTO users (name, email, age, address, profile) VALUES (?, ?, ?, ?, ?)", 
           [name, email, age || null, addressJson, profileJson], function(err) {
        if (err) {
            console.log('POST - Database error code:', err.code);
            console.log('POST - Database error message:', err.message);
            if (err.code === 'SQLITE_CONSTRAINT' || err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
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
            const user = parseUserData(row);
            res.status(201).json({
                message: 'User created successfully',
                data: user
            });
        });
    });
});

// PUT update user by ID
app.put('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, email, age, address, profile } = req.body;
    
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
    
    // Nested fields validation
    const addressError = validateAddress(address);
    if (addressError) {
        return res.status(400).json({ error: addressError });
    }
    
    const profileError = validateProfile(profile);
    if (profileError) {
        return res.status(400).json({ error: profileError });
    }
    
    const addressJson = address ? JSON.stringify(address) : null;
    const profileJson = profile ? JSON.stringify(profile) : null;
    
    db.run("UPDATE users SET name = ?, email = ?, age = ?, address = ?, profile = ? WHERE id = ?", 
           [name, email, age || null, addressJson, profileJson, id], function(err) {
        if (err) {
            console.log('PUT - Database error code:', err.code);
            console.log('PUT - Database error message:', err.message);
            if (err.code === 'SQLITE_CONSTRAINT' || err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
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
            const user = parseUserData(row);
            res.json({
                message: 'User updated successfully',
                data: user
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
            
            const user = parseUserData(row);
            res.json({
                message: 'User deleted successfully',
                data: user
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
