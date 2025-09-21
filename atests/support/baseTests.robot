*** Settings ***
# Import global configuration, authentication functionality, test data, and custom libraries
Resource        ../global_variables.robot                                    # Global variables and configuration
Resource        ../features/auth/login_spec/keywords/login_keywords.robot    # Authentication keywords and functionality
Variables       resources/data/mass_of_tests.yaml                           # Test data definitions and test cases
Library         libraries/baseTests.py                                      # Custom Python library for extended functionality

# =============================================================================
# Base Test Keywords Library
#
# This library provides fundamental keywords and setup functionality that are
# shared across all test suites in the project. It contains common operations
# like browser management, authentication workflows, screenshot capture, and
# test cleanup procedures.
#
# Keyword categories:
# - Browser Management: Browser initialization, configuration, and cleanup
# - Authentication Workflows: Common login sequences and validation
# - Test Lifecycle Management: Setup, teardown, and state management
# - Screenshot and Reporting: Test result capture and documentation
# - Common Utilities: Reusable functionality across test suites
# =============================================================================

*** Keywords ***

You display the Login Page
    [Documentation]    Initializes browser environment and navigates to the SauceDemo login page.
    ...                This keyword sets up the complete browser context needed for test execution,
    ...                including browser configuration, timeout settings, and page navigation.
    ...
    ...                Setup process:
    ...                1. Initialize empty dictionary for test data storage
    ...                2. Configure browser timeout and automation settings
    ...                3. Launch browser with specified configuration
    ...                4. Create new context with download permissions
    ...                5. Navigate to login page and wait for complete load
    ...
    ...                This keyword is commonly used as a starting point for all test scenarios.
    ${DIC_EMPTY}=     Create Dictionary                    # Initialize empty dictionary for test data storage
    Set Browser Timeout    30s                            # Set default timeout for browser operations  
    ${BOOL_HEADLESS}=    Convert To Boolean    ${HEADLESS_FLAG}    # Convert headless flag to proper boolean
    New Browser    ${BROWSER}    headless=${BOOL_HEADLESS}    # Launch browser with configured settings (headless/visible)
    New Context    acceptDownloads=true                   # Create browser context with file download permissions
    New Page    ${URL_SITE}                               # Navigate to SauceDemo application URL
    Wait For Load State    state=networkidle    timeout=20s  # Wait for page to fully load (no network activity)

Successful login testing
    [Documentation]    Complete successful authentication workflow for test preparation.
    ...                This composite keyword executes the full login sequence with valid credentials
    ...                and validates successful authentication. It's commonly used as a test prerequisite
    ...                when tests require an authenticated user state.
    ...
    ...                Authentication flow:
    ...                1. Navigate to login page with browser setup
    ...                2. Perform authentication using default valid credentials
    ...                3. Validate successful login and page transition
    ...
    ...                Usage: Call this keyword in test setup or as first step in authenticated test scenarios
    You display the Login Page         # Initialize browser and navigate to login page
    Perform the site authentication    # Login with valid default credentials 
    Validate if the login was successful    # Confirm authentication success and proper page loading

Steps to Close Browser
    [Documentation]    Comprehensive browser cleanup and test result capture procedure.
    ...                This keyword handles the complete test teardown process including screenshot capture
    ...                for debugging purposes and proper browser resource cleanup. All operations use
    ...                error handling to ensure teardown completes even if individual steps fail.
    ...
    ...                Cleanup sequence:
    ...                1. Brief pause to allow final page operations to complete
    ...                2. Capture screenshot using Playwright's built-in functionality  
    ...                3. Capture additional screenshot to custom output directory
    ...                4. Close browser and release all associated resources
    ...
    ...                All steps ignore errors to ensure complete cleanup even if issues occur.
    Run Keyword And Ignore Error    Sleep    1s                                    # Brief pause for page stabilization
    Run Keyword And Ignore Error                                                   # Capture screenshot using Playwright
    ...    Take Screenshot    filename=${TEST_NAME}    timeout=5s                  # Built-in screenshot with test name
    Run Keyword And Ignore Error                                                   # Capture custom screenshot to output directory
    ...    Capture Page Screenshot      ${OUTPUTDIR}/browser/screenshot/${TEST_NAME}.png    ${TEST_NAME}  # Custom path screenshot
    Run Keyword And Ignore Error    Close Browser                                  # Close browser and cleanup resources