# Robot Framework Test Automation - Paysera Project
Comprehensive test automation suite using Robot Framework with Playwright browser library, featuring Allure reporting and CI/CD integration.

## Application Under Test
**Target Application**: SauceDemo E-commerce Platform  
**URL**: https://www.saucedemo.com/  
**Description**: Demo e-commerce website for testing automation frameworks

### Test Coverage Areas:
- **Authentication**: Login/logout functionality with various user types
- **Product Navigation**: Inventory browsing, filtering, and selection
- **Shopping Cart**: Add/remove items, cart management
- **User Interface**: Burger menu navigation, responsive design elements
- **End-to-End Flows**: Complete purchase workflows

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
cd path/to/robot_paysera

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

#### Robot Framework CLI Issues:
- **'robot' is not recognized**: 
  - Activate virtual environment: `source .venv/bin/activate` (macOS/Linux) or `.venv\Scripts\activate` (Windows)
  - Or use full Python module syntax: `python -m robot`
- **ModuleNotFoundError**: Reinstall Robot Framework: `pip install --upgrade robotframework`

### Project Report using Git Actions:  
chromium browser:  
https://reinaldorossetti.github.io/robot_atdd_playwright_saucedemo/chromium/#  
firefox browser:  
https://reinaldorossetti.github.io/robot_atdd_playwright_saucedemo/firefox/#  
webkit browser:  
https://reinaldorossetti.github.io/robot_atdd_playwright_saucedemo/webkit/#

Na esteira estamos usando em uma PIPELINE o Pabot para rodar em paralelo as features:  
https://github.com/reinaldorossetti/robot_atdd_playwright_saucedemo/blob/main/.github/workflows/test_robot_pabot.yml

### Quick Start (Experienced Users)
If you're experienced with Python development, here's the minimal setup:

```bash
# 1. Ensure Python 3.11+ and Node.js are installed and in PATH
python --version  # Should be 3.11+
node --version    # Any recent version

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

This test project is designed to support **two development teams** working collaboratively on different aspects of the SauceDemo application testing. Each team has a specific set of test responsibilities to ensure comprehensive coverage while avoiding conflicts and enabling parallel development.

### Team Structure and Responsibilities

#### Team 1: Authentication & Shopping Flow
**Focus Areas**: User authentication and shopping cart functionality
- **Authentication Tests**: Login/logout functionality with various user scenarios
- **Shopping Cart Tests**: Complete shopping cart workflow including add/remove items and checkout process

#### Team 2: Authentication & UI Navigation  
**Focus Areas**: User authentication and burger menu navigation
- **Authentication Tests**: Login/logout functionality with various user scenarios  
- **Burger Menu Tests**: Navigation menu functionality including responsive design and user interactions

### Team-Specific Test Execution Commands

#### Team 1 Commands (Auth + Shopping Cart)
```bash
# Run all Team 1 tests (authentication + shopping cart)
robot --loglevel DEBUG:INFO -d my_reports -i "login_tests OR shopping_cart_tests" ./

# Run authentication tests only
robot --loglevel DEBUG:INFO -d my_reports -i login_tests ./

# Run shopping cart tests only  
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_tests ./

# Run specific shopping cart scenarios
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_ok ./
robot --loglevel DEBUG:INFO -d my_reports -i shopping_cart_remove ./

# Run Team 1 tests in parallel
pabot --processes 2 -d my_reports -i "login_tests OR shopping_cart_tests" ./
```

#### Team 2 Commands (Auth + Burger Menu)
```bash
# Run all Team 2 tests (authentication + burger menu)
robot --loglevel DEBUG:INFO -d my_reports -i "login_tests OR burger_menu_tests" ./

# Run authentication tests only
robot --loglevel DEBUG:INFO -d my_reports -i login_tests ./

# Run burger menu tests only
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_tests ./

# Run specific burger menu scenarios
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_open_close ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_navigation ./
robot --loglevel DEBUG:INFO -d my_reports -i burger_menu_overlay ./

# Run Team 2 tests in parallel
pabot --processes 2 -d my_reports -i "login_tests OR burger_menu_tests" ./
```

### Cross-Team Collaboration Guidelines

- **Shared Authentication Tests**: Both teams work with the same authentication test suite, ensuring consistent login/logout functionality across all features
- **Independent Development**: Teams can develop and test their specific UI features independently
- **Parallel Execution**: Teams can run their test suites simultaneously without conflicts
- **Shared Reporting**: Both teams contribute to the same reporting infrastructure and CI/CD pipeline

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
Test across multiple browser engines:
```bash
# Run with Chrome (default)
robot --loglevel DEBUG:INFO -d my_reports -v BROWSER:chromium ./

# Run with Firefox  
robot --loglevel DEBUG:INFO -d my_reports -v BROWSER:firefox ./

# Run with Safari/WebKit
robot --loglevel DEBUG:INFO -d my_reports -v BROWSER:webkit ./
```

### Parallel Execution with Pabot
Execute tests in parallel for faster execution:
```bash
# Run tests in parallel across 4 processes
pabot --processes 4 -d my_reports ./

# Run specific feature tests in parallel
pabot --processes 2 -d my_reports -i shopping_cart_tests ./
```
### Allure Reporting
Generate and serve detailed Allure reports with rich test analytics:
```bash
# Run tests with Allure listener
python -m robot --listener allure_robotframework -d my_reports ./

# Generate Allure HTML report from results
allure generate ./output/allure -o allure-report/

# Serve Allure report locally
allure serve allure-results/

# Run failed tests and regenerate report
python -m robot --listener allure_robotframework --rerunfailed my_reports/output.xml -d my_reports ./
```

## Available Test Tags

### Feature-Level Tags
- `login_tests` - All authentication related tests
- `burger_menu_tests` - All burger menu navigation tests  
- `shopping_cart_tests` - All shopping cart functionality tests

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
│   │   ├── elements/                         # Shared page elements (locators) across features
│   │   │   └── burger_menu_page.yaml        # Common UI elements for burger menu
│   │   ├── keywords/                         # Shared keywords library across features
│   │   │   └── burger_menu_keywords.robot   # Reusable actions for burger menu
│   │   ├── auth/                            # Authentication feature tests
│   │   │   └── login_spec/                  # Login specification tests
│   │   │       ├── elements/                # Login-specific page elements
│   │   │       │   └── login_page.yaml     # Login page locators
│   │   │       ├── keywords/                # Login-specific keywords
│   │   │       │   └── login_keywords.robot # Login action keywords
│   │   │       └── login_tests.robot       # Login test scenarios
│   │   └── ui_navigation/                   # UI Navigation feature tests
│   │       ├── burger_menu_spec/            # Burger menu specification tests
│   │       │   └── burger_menu_tests.robot # Burger menu test scenarios
│   │       └── shopping_cart_spec/          # Shopping cart specification tests
│   │           ├── elements/                # Cart-specific page elements
│   │           │   └── shopping_cart_page.yaml # Shopping cart locators
│   │           ├── keywords/                # Cart-specific keywords
│   │           │   └── shopping_cart_keywords.robot # Cart action keywords
│   │           └── shopping_cart_tests.robot # Shopping cart test scenarios
│   ├── support/                             # Common test utilities and base functions
│   │   ├── baseTests.robot                 # Base keywords used across all tests
│   │   ├── libraries/                      # Custom Python libraries
│   │   │   └── baseTests.py               # Custom Python test utilities
│   │   └── resources/                      # Test data and configuration
│   │       └── data/                       # Test data files
│   │           └── mass_of_tests.yaml     # Bulk test data configuration
│   └── global_variables.robot              # Global variables and imports
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
