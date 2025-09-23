# Robot Framework Test Automation - Paysera Project
Comprehensive test automation suite using Robot Framework with Playwright browser library, featuring Allure reporting and CI/CD integration.

## API Server for Testing

This project includes a simple Node.js + Express API server with SQLite database for testing purposes. The API provides CRUD operations for user management and is designed to be used with Robot Framework tests.

### Quick Start - API Server

#### Step 1: Install Node.js
1. Download and install Node.js from [nodejs.org](https://nodejs.org/) (LTS version recommended)
2. Verify installation:
   ```bash
   node --version
   npm --version
   ```

#### Step 2: Install API Dependencies
```bash
npm install
```

#### Step 3: Start the API Server
```bash
# Development mode with auto-reload
npm run dev

# Or production mode
npm start
```

The server will start at `http://localhost:3000`

#### Step 4: Test API Endpoints
You can test the API using curl, Postman, or the included Robot Framework tests:

```bash
# Health check
curl http://localhost:3000/

# Get all users
curl http://localhost:3000/users

# Create a new user (basic data)
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com", "age": 30}'

# Create a user with nested address and profile data
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com", 
    "age": 28,
    "address": {
      "street": "123 Main St",
      "city": "New York",
      "state": "NY",
      "zip_code": "10001",
      "country": "USA"
    },
    "profile": {
      "occupation": "Software Developer",
      "company": "Tech Corp",
      "phone": "+1-555-123-4567",
      "preferences": {
        "newsletter": true,
        "notifications": false,
        "theme": "dark"
      }
    }
  }'

# Get user by ID
curl http://localhost:3000/users/1

# Update user (basic fields)
curl -X PUT http://localhost:3000/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "John Smith", "email": "johnsmith@example.com", "age": 31}'

# Update user with nested data
curl -X PUT http://localhost:3000/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith Updated",
    "address": {
      "street": "456 Updated Ave",
      "city": "Boston",
      "state": "MA"
    },
    "profile": {
      "company": "New Company Inc",
      "preferences": {
        "theme": "light"
      }
    }
  }'

# Delete user
curl -X DELETE http://localhost:3000/users/1
```

### API Endpoints
- `GET /` - API health check and endpoint list (returns server status and available endpoints)
- `GET /users` - Get all users with count and pagination support
- `GET /users/:id` - Get specific user by ID (supports nested address and profile data)
- `POST /users` - Create new user (supports nested address and profile objects)  
- `PUT /users/:id` - Update existing user by ID (supports partial and complete updates)
- `DELETE /users/:id` - Delete user by ID (returns deleted user data for confirmation)

### Running API Tests with Robot Framework
```bash
# Run API tests (make sure API server is running first)
robot atests/features/common/api/api_tests.robot

# Run specific test tags  
robot --include positive_test atests/features/common/api/api_tests.robot
robot --include negative_test atests/features/common/api/api_tests.robot

# Run API health check tests
robot --include smoke_test atests/features/common/api/api_tests.robot
```

### Database
- SQLite database file: `demo_resourses/database.sqlite`
- Automatically created with sample data on first run
- User table with fields: id, name, email, age, address (JSON), profile (JSON), created_at
- Supports complex user data with nested address and profile information
- Sample users are automatically created if the database is empty

---

## Prerequisites & Installation Guide for Beginners

### Step 1: Install Python 3.11+
**Python 3.11 or higher is required for this project.**

#### Windows:
1. Go to [Python Downloads](https://www.python.org/downloads/release/python-3110/)
2. Download "Windows installer (64-bit)" or "Windows installer (32-bit)" based on your system
3. **⚠️ IMPORTANT**: During installation, check "Add Python to PATH" checkbox
4. Click "Install Now"
5. Verify installation:
   ```cmd
   python --version
   # Should output: Python 3.11.x
   ```

#### macOS:
1. Go to [Python Downloads](https://www.python.org/downloads/release/python-3110/)
2. Download "macOS 64-bit universal2 installer"
3. Run the installer and follow the prompts
4. Verify installation:
   ```bash
   python3 --version
   # Should output: Python 3.11.x
   ```

#### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-pip
```

### Step 2: Verify and Install pip
**pip** is usually included with Python 3.4+, but let's verify:

#### Check if pip is installed:
```bash
# Windows
pip --version

# macOS/Linux  
pip3 --version
```

#### If pip is not installed:
**Windows:**
1. Download [get-pip.py](https://bootstrap.pypa.io/get-pip.py)
2. Run: `python get-pip.py`

**macOS/Linux:**
```bash
# Option 1: Using package manager
sudo apt install python3-pip  # Ubuntu/Debian
brew install python3          # macOS with Homebrew

# Option 2: Manual installation
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
```

### Step 3: Verify PATH Environment Variables
**Both Python and pip must be in your system PATH:**

#### Windows - Add to PATH manually:
1. Open "Environment Variables" (search in Start menu)
2. Under "User variables", find and select "Path", click "Edit"
3. Add these paths (adjust Python version if needed):
   ```
   C:\Users\[YourUsername]\AppData\Local\Programs\Python\Python311\
   C:\Users\[YourUsername]\AppData\Local\Programs\Python\Python311\Scripts\
   ```
4. Click "OK" and restart Command Prompt/PowerShell

#### Verify PATH (all platforms):
```bash
# These commands should work from any directory:
python --version    # or python3 --version on macOS/Linux
pip --version       # or pip3 --version on macOS/Linux
```

### Step 4: Install Node.js (Required for Playwright)
**Robot Framework Browser library requires Node.js:**

1. Go to [Node.js Downloads](https://nodejs.org/en/download)
2. Download and install the LTS version
3. Verify installation:
   ```bash
   node --version
   npm --version
   ```

### Step 5: Set Up Virtual Environment (Recommended)
**Virtual environments isolate project dependencies:**

```bash
# Navigate to your project directory
# Create virtual environment
python -m venv .venv
# or on macOS/Linux: python3 -m venv .venv

# Activate virtual environment
# Windows (Command Prompt):
.venv\Scripts\activate

# Windows (PowerShell):
.venv\Scripts\Activate.ps1

# macOS/Linux:
source .venv/bin/activate

# You should see (.venv) at the beginning of your command prompt
```

#### Deactivate virtual environment (when done):
```bash
deactivate
```

### Step 6: Install Project Dependencies
**With virtual environment activated:**

```bash
# Install all required packages
pip install -r requirements.txt

# Initialize Playwright browsers
rfbrowser init

# Verify Robot Framework installation
robot --version
```

### Step 7: Install Additional Command Line Tools

#### Install Allure CLI (Required for Allure Reports)
**Allure command line tool is needed to generate and serve HTML reports:**

**⚠️ IMPORTANT: JDK 8+ is required for Allure server to work properly.**

#### Step 1: Install Java Development Kit (JDK)
**Allure server requires minimum JDK 8 or higher:**

```bash
# Check if Java is already installed
java -version
# Should output: openjdk version "X.X.X" or similar

# If Java is not installed, download from:
# https://adoptium.net/ (recommended)
# or https://www.oracle.com/java/technologies/downloads/
```

**Installation by platform:**
- **Windows**: Download and install JDK from [Adoptium](https://adoptium.net/)
- **macOS**: `brew install openjdk` or download from Adoptium
- **Linux (Ubuntu/Debian)**: `sudo apt install openjdk-11-jdk`

**Verify Java installation:**
```bash
java -version
javac -version
# Both commands should work and show version 8+
```

#### Step 2: Install Allure CLI
```bash
# Install Allure CLI globally via npm
npm install -g allure-commandline

# Verify Allure installation
allure --version
# Should output something like: 2.24.0

# Alternative installation methods:
# Windows (using Chocolatey):
# choco install allure

# macOS (using Homebrew):
# brew install allure

# Linux (manual installation):
# Download from: https://github.com/allure-framework/allure2/releases
```

#### Verify Robot Framework CLI Access
**Make sure you can run Robot Framework from command line:**

```bash
# These commands should work from any directory:
robot --version
python -m robot --version

# If 'robot' command is not found, you can always use:
python -m robot [options] [test_files]
```

**Note:** If `robot` command is not available globally, ensure your virtual environment is activated or Python Scripts directory is in PATH.

### Common Troubleshooting:

#### Windows PowerShell Execution Policy Error:
If you see "execution of scripts is disabled", run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### PATH Issues:
- Restart your terminal/IDE after modifying PATH
- Use full paths if commands aren't found:
  ```bash
  C:\Users\[Username]\AppData\Local\Programs\Python\Python311\python.exe --version
  ```

#### Permission Issues (macOS/Linux):
- Use `sudo` only when necessary for system-wide installations
- Prefer virtual environments to avoid permission conflicts

#### Allure CLI Issues:
- **Command not found**: Ensure Node.js is installed and npm is in PATH
- **Permission denied**: Use `sudo npm install -g allure-commandline` on macOS/Linux
- **Version conflicts**: Uninstall and reinstall: `npm uninstall -g allure-commandline && npm install -g allure-commandline`

#### JDK/Java Issues (Required for Allure Server):
- **Java not found**: Install JDK 8+ from [Adoptium](https://adoptium.net/) or use package manager
- **Allure server fails to start**: Verify Java installation with `java -version` (should show version 8+)
- **"JAVA_HOME not set"**: Set JAVA_HOME environment variable to your JDK installation path
- **PATH issues**: Ensure Java bin directory is in your system PATH

#### Robot Framework CLI Issues:
- **'robot' is not recognized**: 
  - Activate virtual environment: `source .venv/bin/activate` (macOS/Linux) or `.venv\Scripts\activate` (Windows)
  - Or use full Python module syntax: `python -m robot`
- **ModuleNotFoundError**: Reinstall Robot Framework: `pip install --upgrade robotframework`

### Continuous Integration and Reports
This project supports automated test execution across multiple browsers:
- **Chromium**: Default browser for most test scenarios
- **Firefox**: Cross-browser compatibility testing
- **WebKit**: Safari/WebKit engine testing

Test results are generated using Allure reporting framework for comprehensive test analytics and visual reports.

This project uses Pabot for parallel test execution in CI/CD pipelines. See GitHub Actions workflow configuration for detailed implementation examples.

### Quick Start (Experienced Users)
If you're experienced with Python development, here's the minimal setup:

```bash
# 1. Ensure Python 3.11+, Node.js, and JDK 8+ are installed and in PATH
python --version  # Should be 3.11+
node --version    # Any recent version
java -version     # Should be 8+ (required for Allure server)

# 2. Create and activate virtual environment (optional but recommended)
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# or .venv\Scripts\activate  # Windows

# 3. Install dependencies and initialize browsers
pip install -r requirements.txt
rfbrowser init

# 4. Install Allure CLI for reports (optional but recommended)
npm install -g allure-commandline
allure --version  # Verify installation

# 5. Run tests
python -m robot -d my_reports ./

# 6. Generate Allure report (if Allure CLI installed)
allure serve allure-results/
```

**For beginners or detailed installation steps, see the "Prerequisites & Installation Guide for Beginners" section above.**

**Framework Versions:**
- Robot Framework: 6.0.2+ (Latest stable version)
- Release Notes: https://github.com/robotframework/robotframework/blob/master/doc/releasenotes/rf-6.0.2.rst

## Getting Started (Step by step)

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd robot_paysera
pip install -r requirements.txt
rfbrowser init
```

### 2. Run Sample Tests
```bash
# Run all tests with detailed reporting
python -m robot -d my_reports ./

# Run specific feature
python -m robot -d my_reports -i burger_menu_tests ./
```

### 3. View Reports
```bash
# Open HTML report (built-in Robot Framework report)
open my_reports/report.html

# Generate and view Allure report (if Allure CLI is installed)
allure serve allure-results/

# Note: Install Allure CLI first: npm install -g allure-commandline
```

WINDOWS ONLY: Add path to Browser library: 
C:\Users\<user_name_here>\AppData\Roaming\Python\Python311\site-packages\Browser


## Team-Based Test Execution Strategy

This test project is designed to support **multiple development teams** working collaboratively on different aspects of the SauceDemo application testing. Teams share common functionality while maintaining their specific feature responsibilities to ensure comprehensive coverage while avoiding conflicts and enabling parallel development.

### Team Structure and Responsibilities

#### Team Alpha: API Enhanced Testing & Burger Menu
**Focus Areas**: Enhanced API testing and burger menu navigation functionality
- **API Improved Tests**: Advanced API testing scenarios with enhanced error handling and bulk operations
- **Burger Menu Tests**: Navigation menu functionality including responsive design and user interactions

#### Team Beta: Shopping Cart & E-commerce Flow
**Focus Areas**: Shopping cart functionality and complete e-commerce workflow
- **Shopping Cart Tests**: Complete shopping cart workflow including add/remove items and checkout process

#### Common Features: Shared Authentication & API
**Focus Areas**: Shared functionality across teams
- **Authentication Tests**: Login/logout functionality with various user scenarios used by all teams
- **API Tests**: Basic API testing functionality shared across teams

### Team-Specific Test Execution Commands

#### Team Alpha Commands (API Improved + Burger Menu)
```bash
# Run all Team Alpha tests (API improved + burger menu)
robot --loglevel DEBUG:INFO -d my_reports atests/features/team_alpha/

# Run API improved tests only
robot --loglevel DEBUG:INFO -d my_reports atests/features/team_alpha/api_improved/

# Run burger menu tests only
robot --loglevel DEBUG:INFO -d my_reports atests/features/team_alpha/burger_menu_spec/

# Run specific burger menu scenarios
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_open_close ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_navigation ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_overlay ./

# Run Team Alpha tests in parallel
pabot --processes 2 -d my_reports atests/features/team_alpha/
```

#### Team Beta Commands (Shopping Cart)
```bash
# Run all Team Beta tests (shopping cart)
robot --loglevel DEBUG:INFO -d my_reports atests/features/team_beta/

# Run with fast execution (headless + error-only logging)
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d my_reports atests/features/team_beta/

# Run shopping cart tests only with debug configuration
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d my_reports atests/features/team_beta/shopping_cart_spec/

# Run specific shopping cart scenarios
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_ok ./
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_remove ./

# Run Team Beta tests in parallel with variable overrides
pabot --processes 2 -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports atests/features/team_beta/
```

#### Common Features Commands (Authentication + API)
```bash
# Run all common features tests (authentication + API)
robot --loglevel DEBUG:INFO -d my_reports atests/features/common/

# Run with production-like settings (headless + info logging)
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO -d my_reports atests/features/common/

# Run authentication tests only with debugging
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d my_reports atests/features/common/auth/

# Run API tests only (headless recommended for API tests)
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO -d my_reports atests/features/common/api/

# Run specific login scenarios with variable overrides
robot -v LOG_LEVEL:DEBUG -d my_reports -i login_ok ./
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d my_reports -i login_negative ./

# Run common features in parallel with optimized settings
pabot --processes 2 -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports atests/features/common/
```

### Cross-Team Collaboration Guidelines

- **Common Features**: Both teams use shared authentication and API test suites from the `common/` folder, ensuring consistent functionality across all features
- **Team-Specific Features**: Team Alpha focuses on enhanced API testing and burger menu, Team Beta on shopping cart functionality
- **Independent Development**: Teams can develop and test their specific features independently under their respective folders
- **Parallel Execution**: Teams can run their test suites simultaneously without conflicts using team-specific paths
- **Shared Reporting**: All teams contribute to the same reporting infrastructure and CI/CD pipeline

### Full Test Suite Execution
```bash
# Run all tests across both teams (integration testing)
python -m robot -d my_reports ./

# Run tests with team-based parallel execution
pabot --processes 4 --testlevelsplit -d my_reports ./
```

## Test Execution Commands

### Run All Tests
Execute all tests in the project with HTML and XML reports:
```bash
python -m robot -d my_reports ./
```

### Run Tests by Feature Tags
Execute tests grouped by functional areas:
```bash
# Authentication feature tests
robot --loglevel DEBUG:INFO -d my_reports -i login_tests ./

# UI Navigation feature tests  
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_tests ./
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_tests ./
```

### Run Tests by Specific Scenarios
Execute individual test scenarios for focused testing:
```bash
# Burger menu functionality
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_open_close ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_navigation ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_overlay ./

# Shopping cart functionality  
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_ok ./
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_remove ./

# Login functionality
robot --loglevel DEBUG:INFO -d my_reports -i login_ok ./
robot --loglevel DEBUG:INFO -d my_reports -i login_negative ./
```

### Run Tests with Different Browsers
Test across multiple browser engines with variable overrides:
```bash
# Run with Chrome (default)
robot --loglevel DEBUG:INFO -d my_reports -v BROWSER:chromium ./

# Run with Chrome in headless mode with INFO logging
robot -v BROWSER:chromium -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO -d my_reports ./

# Run with Firefox with debug configuration
robot -v BROWSER:firefox -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d my_reports ./

# Run with Safari/WebKit in production-like mode
robot -v BROWSER:webkit -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports ./

# Cross-browser testing with optimized logging
robot -v BROWSER:chromium -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d chromium_reports ./
robot -v BROWSER:firefox -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d firefox_reports ./
robot -v BROWSER:webkit -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d webkit_reports ./
```

### Parallel Execution with Pabot
Execute tests in parallel for faster execution with variable overrides:
```bash
# Run tests in parallel across 4 processes (default settings)
pabot --processes 4 -d my_reports ./

# Run tests in parallel with headless mode and minimal logging
pabot --processes 4 -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports ./

# Run specific feature tests in parallel with optimized settings
pabot --processes 2 -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO -d my_reports -i shopping_cart_tests ./

# Cross-browser parallel execution with variable overrides
pabot --processes 2 -v BROWSER:chromium -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d chromium_parallel ./
pabot --processes 2 -v BROWSER:firefox -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d firefox_parallel ./
```

## Variable Override Configuration

This project supports dynamic variable overriding for key configuration settings through command line arguments or environment variables. This allows flexible test execution without modifying source files.

### Available Variables for Override

#### HEADLESS_FLAG
Control browser visibility during test execution:
- `true` - Run browser in headless mode (no UI, faster execution)
- `false` - Run browser with visible UI (useful for debugging)

#### LOG_LEVEL
Control the verbosity of test execution logging:
- `TRACE` - Maximum detail logging (most verbose)
- `DEBUG` - Detailed logging for debugging (default)
- `INFO` - Informational messages only
- `WARN` - Warning and error messages only
- `ERROR` - Error messages only (least verbose)

### Override Methods

#### Method 1: Command Line Variables (Recommended)
Use the `-v` flag to override variables directly in the command:

```bash
# Single variable override
robot -v HEADLESS_FLAG:true atests/

# Multiple variable override
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO atests/

# Override with specific test execution
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports atests/features/team_alpha/

# Run tests with headless mode and minimal logging
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d my_reports ./

# Debug mode with visible browser and verbose logging
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d my_reports ./
```

#### Method 2: Environment Variables
Set environment variables before running tests:

**Windows PowerShell:**
```powershell
# Set environment variables
$env:HEADLESS_FLAG="true"
$env:LOG_LEVEL="INFO"
robot atests/

# Or set and run in one command
$env:HEADLESS_FLAG="true"; $env:LOG_LEVEL="INFO"; robot -d my_reports ./
```

**Windows Command Prompt:**
```cmd
# Set environment variables
set HEADLESS_FLAG=true
set LOG_LEVEL=INFO
robot atests/

# Or set and run in one command
set HEADLESS_FLAG=true && set LOG_LEVEL=INFO && robot -d my_reports ./
```

**Linux/macOS:**
```bash
# Set environment variables
export HEADLESS_FLAG=true
export LOG_LEVEL=INFO
robot atests/

# Or set and run in one command
HEADLESS_FLAG=true LOG_LEVEL=INFO robot -d my_reports ./
```

### Practical Override Examples

#### CI/CD Pipeline Configuration
```bash
# Headless execution with minimal logging for faster CI/CD
robot -v HEADLESS_FLAG:true -v LOG_LEVEL:ERROR -d ci_reports ./

# Parallel execution with variable overrides
pabot --processes 4 -v HEADLESS_FLAG:true -v LOG_LEVEL:WARN -d my_reports ./
```

#### Development and Debugging
```bash
# Debug mode: visible browser with detailed logging
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d debug_reports ./

# Team-specific testing with overrides
robot -v HEADLESS_FLAG:false -v LOG_LEVEL:INFO -d my_reports atests/features/team_alpha/burger_menu_spec/
```

#### Cross-Browser Testing with Overrides
```bash
# Test with different browsers and configurations
robot -v BROWSER:chromium -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO -d chromium_reports ./
robot -v BROWSER:firefox -v HEADLESS_FLAG:false -v LOG_LEVEL:DEBUG -d firefox_reports ./
```

### Default Values
If no override is specified, the system uses these defaults:
- `HEADLESS_FLAG`: `false` (browser UI visible)
- `LOG_LEVEL`: `DEBUG` (detailed logging)

These defaults are defined in `atests/features/common/common_global_variables.robot` and can be modified there if needed.
### Allure Reporting
Generate and serve detailed Allure reports with rich test analytics.
**Note:** Allure automatically creates required directories (`allure-results`, `allure-report`), no manual creation needed.
```bash
# ✅ RECOMMENDED: Clean results and run tests with Allure listener
Remove-Item allure-results -Recurse -Force -ErrorAction SilentlyContinue
python -m robot --listener "allure_robotframework:./allure-results" -d my_reports ./

# Generate Allure HTML report from results
allure generate allure-results -o allure-report --clean

# Open Allure report in browser
allure open allure-report

# ⚠️ One-line command (clears previous results automatically)
Remove-Item allure-results -Recurse -Force -ErrorAction SilentlyContinue && python -m robot --listener "allure_robotframework:./allure-results" -d my_reports ./ && allure generate allure-results -o allure-report --clean

# Run failed tests and regenerate report
Remove-Item allure-results -Recurse -Force -ErrorAction SilentlyContinue
python -m robot --listener "allure_robotframework:./allure-results" --rerunfailed my_reports/output.xml -d my_reports ./
```

## Available Test Tags

### Feature-Level Tags
- `login_tests` - All authentication related tests
- `burger_menu_tests` - All burger menu navigation tests  
- `shopping_cart_tests` - All shopping cart functionality tests
- `api_tests` - All API testing scenarios (CRUD operations, validation, error handling)

### Scenario-Level Tags
- `login_ok` - Successful login scenarios
- `login_negative` - Failed login scenarios  
- `burger_menu_open_close` - Menu open/close functionality
- `burger_menu_navigation` - Menu navigation scenarios
- `burger_menu_overlay` - Overlay interaction tests
- `burger_menu_items` - Menu items validation
- `burger_menu_multiple_ops` - Complex menu operations
- `shopping_cart_ok` - Successful cart operations
- `shopping_cart_remove` - Cart item removal tests

### API-Specific Test Tags
- `smoke_test` - API health check and basic connectivity tests
- `positive_test` - Successful API operation scenarios
- `negative_test` - Error handling and validation tests
- `crud_operation` - Create, Read, Update, Delete operations
- `user_creation` - User creation scenarios
- `user_retrieval` - User data retrieval tests
- `nested_test` - Complex nested data structure tests

### Usage Examples
```bash
# Run all negative test scenarios
robot --loglevel DEBUG:INFO -d my_reports -i *negative ./

# Run all menu-related tests  
robot --loglevel DEBUG:INFO -d my_reports -i *menu* ./

# Exclude long-running tests
robot --loglevel DEBUG:INFO -d my_reports -e slow ./
```

Project Structure Conventions
===============================

> Folder structure and naming conventions following Robot Framework best practices.

### Hybrid Page Object Model directory pattern with shared resources.
```
├── atests/                                    # Main test automation folder (root code)
│   ├── features/                             # Feature-based test organization
│   │   ├── common/                          # Common/shared features across teams
│   │   │   ├── common_global_variables.robot # ✅ Global variables with override support
│   │   │   │                                # Supports HEADLESS_FLAG and LOG_LEVEL override
│   │   │   │                                # via command line (-v) or environment variables
│   │   │   ├── api/                         # API testing features
│   │   │   │   ├── elements/                # API-specific elements
│   │   │   │   │   └── api_tests.yaml      # API test configuration
│   │   │   │   ├── keywords/                # API-specific keywords  
│   │   │   │   │   └── api_tests_keywords.robot # API action keywords
│   │   │   │   └── api_tests.robot         # API test scenarios
│   │   │   └── auth/                        # Authentication feature tests
│   │   │       └── login_spec/              # Login specification tests
│   │   │           ├── elements/            # Login-specific page elements
│   │   │           │   └── login_page.yaml # Login page locators
│   │   │           ├── keywords/            # Login-specific keywords
│   │   │           │   └── login_keywords.robot # Login action keywords
│   │   │           └── login_tests.robot   # Login test scenarios
│   │   ├── team_alpha/                      # Team Alpha specific features
│   │   │   ├── team_alpha_variables.robot   # Team Alpha specific variables
│   │   │   ├── api_improved/                # Improved API testing
│   │   │   │   └── api_tests_improved.robot # Enhanced API test scenarios
│   │   │   └── burger_menu_spec/            # Burger menu specification tests
│   │   │       ├── elements/                # Burger menu-specific page elements  
│   │   │       │   └── burger_menu_page.yaml # Burger menu locators
│   │   │       ├── keywords/                # Burger menu-specific keywords
│   │   │       │   └── burger_menu_keywords.robot # Burger menu action keywords
│   │   │       └── burger_menu_tests.robot # Burger menu test scenarios
│   │   └── team_beta/                       # Team Beta specific features
│   │       ├── team_beta_global_variables.robot # Team Beta specific variables  
│   │       └── shopping_cart_spec/          # Shopping cart specification tests
│   │           ├── elements/                # Cart-specific page elements
│   │           │   └── shopping_cart_page.yaml # Shopping cart locators
│   │           ├── keywords/                # Cart-specific keywords
│   │           │   └── shopping_cart_keywords.robot # Cart action keywords
│   │           └── shopping_cart_tests.robot # Shopping cart test scenarios
│   └── support/                             # Common test utilities and base functions
│       ├── baseTests.robot                 # Base keywords used across all tests
│       ├── libraries/                      # Custom Python libraries
│       │   └── baseTests.py               # Custom Python test utilities
│       └── resources/                      # Test data and configuration
│           └── data/                       # Test data files
│               └── mass_of_tests.yaml     # Bulk test data configuration
├── browser/                                # Browser artifacts (screenshots, traces)
│   ├── screenshot/                         # Test execution screenshots
│   └── traces/                            # Playwright traces for debugging
├── my_reports/                            # Test execution reports
├── allure-report/                         # Allure HTML reports
├── allure-results/                        # Allure raw results
├── output/                                # Robot Framework output files
├── .gitignore                             # Git ignore configuration
├── LICENSE                                # Project license
├── README.md                              # Project documentation
└── requirements.txt                       # Python dependencies
```

## Architecture Design Principles

### Hybrid Page Object Model with Shared Resources
This project implements a **Hybrid Page Object Model** that combines:

- **Shared Resources**: Common keywords and elements that can be reused across different features (located in `features/keywords/` and `features/elements/`)
- **Feature-Specific Resources**: Specialized keywords and elements for specific features (located within each spec folder)
- **Test Organization**: Feature-based organization with specification-level test grouping

### Key Benefits:
- **Reusability**: Shared keywords reduce code duplication
- **Maintainability**: Centralized element management for common UI components
- **Scalability**: Easy to add new features without restructuring existing tests
- **Modularity**: Each feature can have its own specific resources when needed

### Naming Conventions:
- **Files**: Use lowercase with underscores for separation (e.g., `burger_menu_tests.robot`)
- **Folders**: Use lowercase with underscores for consistency  
- **Variables**: Use UPPERCASE for constants (e.g., `BURGER_MENU_BUTTON`)
- **YAML Files**: Store locators and configuration data to separate test logic from UI elements
- **Test Tags**: Use descriptive tags for test organization and selective execution

### File Organization Rules:
1. **Test Files**: End with `_tests.robot` and contain actual test scenarios
2. **Keywords Files**: End with `_keywords.robot` and contain reusable actions
3. **Elements Files**: End with `_page.yaml` and contain UI locators/selectors
4. **Shared Resources**: Place common elements in `features/elements/` and keywords in `features/keywords/`
5. **Specific Resources**: Place feature-specific resources within the respective spec folder

** This project follows Robot Framework best practices and industry standards.

## Project Dependencies

### Core Testing Libraries:
```
robotframework>=6.0.2              # Main test automation framework
robotframework-browser>=16.2.0     # Playwright-based browser library  
robotframework-pabot>=2.15.0       # Parallel test execution
```

### Reporting & Analytics:
```
allure-robotframework>=2.13.1      # Allure test reporting
allure-python-commons>=2.15.0      # Allure core functionality
```

### Utilities & Data Handling:
```
robotframework-faker>=5.0.0        # Test data generation
robotframework-jsonlibrary>=0.5    # JSON data manipulation
pyyaml>=6.0.2                      # YAML configuration files
```

### Development Tools:
- **Browser Support**: Chromium, Firefox, WebKit via Playwright
- **CI/CD Integration**: GitHub Actions workflows included
- **IDE Support**: VS Code extensions recommended

## IDE Setup and Extensions

### Robot Framework Language Server (Recommended)
For enhanced development experience with syntax highlighting, code completion, and debugging support, install the **Robot Framework Language Server** extension:

#### Visual Studio Code:
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
3. Search for "Robot Framework Language Server"
4. Install the extension by **Robocorp**
5. Restart VS Code

#### Extension Features:
- **Syntax Highlighting**: Proper color coding for Robot Framework keywords, variables, and test structures
- **Auto-completion**: IntelliSense for keywords, variables, and imports
- **Go to Definition**: Navigate to keyword definitions across files
- **Error Detection**: Real-time syntax error highlighting
- **Code Formatting**: Automatic code formatting and indentation
- **Debugging Support**: Step-through debugging capabilities
- **Test Discovery**: Visual test tree explorer

#### Alternative IDEs:
- **PyCharm/IntelliJ**: Install "IntelliBot @SeleniumLibrary Patched" plugin
- **Sublime Text**: Install "Robot Framework" package
- **Atom**: Install "language-robot-framework" package

#### Configuration (Optional):

##### VS Code Configuration:
Create `.vscode/settings.json` in your project root for optimal experience:
```json
{
    "robot.language-server.python": ".venv/Scripts/python.exe",
    "robot.libraries.libdoc.needsArgs": [
        "Browser"
    ],
    "robot.variables": {
        "BROWSER": "chromium"
    }
}
```

##### PyCharm Configuration:
PyCharm doesn't use `settings.json`. Instead, configure through the IDE:

1. **File → Settings** (or PyCharm → Preferences on macOS)
2. **Project Settings → Project Interpreter**:
   - Set interpreter to your virtual environment: `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (macOS/Linux)
3. **Languages & Frameworks → Robot Framework**:
   - Enable Robot Framework support
   - Set Robot Framework path: usually auto-detected
   - Configure library paths if needed
4. **File Types**: Ensure `.robot` files are associated with Robot Framework file type

**PyCharm Project Configuration Files** (automatically created):
```
├── .idea/
│   ├── misc.xml           # Python interpreter settings
│   ├── modules.xml        # Project modules configuration  
│   ├── workspace.xml      # IDE workspace settings
│   └── [project-name].iml # Module configuration
```

**Note:** PyCharm stores its configuration in the `.idea/` folder. The Language Server significantly improves productivity and reduces syntax errors during test development.

References:      
robotframework:  
https://docs.robotframework.org/docs  
https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html  
browser library:  
https://robotframework-browser.org   
https://marketsquare.github.io/robotframework-browser/Browser.html  
https://github.com/MarketSquare/robotframework-browser#robotframework-browser  

Courses of Robot Framework (PT_BR):  
https://www.udemy.com/course/automacao-de-testes-com-robot-framework-basico/  
https://www.udemy.com/course/automacao-de-testes-com-robot-framework-avancado   
