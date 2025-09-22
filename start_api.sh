#!/bin/bash

echo "Starting API Server..."
echo

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js is not installed or not in PATH"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if package.json exists
if [ ! -f package.json ]; then
    echo "ERROR: package.json not found"
    echo "Make sure you are running this from the project root directory"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d node_modules ]; then
    echo "Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install dependencies"
        exit 1
    fi
    echo
fi

# Start the API server
echo "Starting API server on http://localhost:3000"
echo "Press Ctrl+C to stop the server"
echo

node demo_resourses/api.js
