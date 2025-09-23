*** Settings ***
# Import required libraries for test automation framework
Library        Browser           # Playwright browser automation library for web testing
Library        Collections       # Python collections library for data structure operations  
Library        FakerLibrary      # Library for generating fake/mock test data
Library        String            # Python string manipulation library
Library        allure_robotframework    WITH NAME    Allure    # Allure reporting integration

# =============================================================================
# Team Alpha Variables and Configuration
#
# This file contains variables and configuration settings specific to Team Alpha
# testing requirements. Team Alpha focuses on API testing and burger menu UI
# functionality within the SauceDemo test automation project.
#
# Team Alpha Test Areas:
# - API Testing: Backend API endpoints, test data, and validation
# - Burger Menu UI: Navigation menu functionality and UI components
#
# Variable Categories:
# - Application URLs: SauceDemo web app and API endpoints
# - API Configuration: Backend API settings and test data
# - Browser Configuration: Browser settings for UI testing
# - Test Configuration: Team-specific logging and behavior settings
# - UI Element Paths: Burger menu and navigation element locators
# =============================================================================


*** Variables ***

# APPLICATION CONFIGURATION
# URLs and endpoints for Team Alpha applications under test
${URL_SITE}              https://www.saucedemo.com/    # Base URL for SauceDemo e-commerce application
${BASE_URL}              http://localhost:3000         # Base URL for API server testing

# FILE SYSTEM PATHS
# Paths to test resources, data files, and project directories
${PATH_FEATURES}         ${EXECDIR}/atests/features    # Root directory for test feature files
${YAML_FILE}             ${EXECDIR}/atests/support/resources/data/mass_of_tests.yaml    # Test data configuration file
${API_YAML_FILE}         ${EXECDIR}/atests/features/common/api/elements/api_tests.yaml    # API test data configuration

# API TESTING CONFIGURATION
# Settings and constants for API testing scenarios
${NON_EXISTENT_USER_ID}  99999                         # User ID that doesn't exist for negative testing
${API_TIMEOUT}           30s                           # Default timeout for API operations

# BROWSER CONFIGURATION  
# Settings for browser automation and web driver behavior
${BROWSER}               chromium                      # Browser engine to use (chromium/firefox/webkit)
${HEADLESS_FLAG}         %{HEADLESS_FLAG=${false}}                           # Run browser in headless mode (true/false) - can be overridden via env var
${HEADLESS_MODE}         ${HEADLESS_FLAG}                                    # Alias for backward compatibility

# TEST CONFIGURATION
# Team Alpha specific test execution settings and behavior control
${LOG_LEVEL}             %{LOG_LEVEL=DEBUG}                                  # Logging level for test execution - can be overridden via env var
${DIC_EMPTY}                                          # Empty dictionary placeholder for initialization

# BURGER MENU UI CONFIGURATION
# Settings for burger menu and navigation testing
${MENU_TIMEOUT}          10s                          # Default timeout for menu operations
${PAGE_LOAD_TIMEOUT}     20s                          # Timeout for page navigation after menu clicks