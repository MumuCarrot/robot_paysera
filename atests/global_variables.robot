*** Settings ***
# Import required libraries for test automation framework
Library        Browser           # Playwright browser automation library for web testing
Library        Collections       # Python collections library for data structure operations  
Library        FakerLibrary      # Library for generating fake/mock test data
Library        String            # Python string manipulation library
Library        allure_robotframework    WITH NAME    Allure    # Allure reporting integration

# =============================================================================
# Global Variables and Configuration
#
# This file contains global variables and configuration settings that are shared
# across all test suites and modules in the SauceDemo test automation project.
# These variables define the test environment, browser settings, file paths,
# and other cross-cutting configuration needed for comprehensive test execution.
#
# Variable Categories:
# - Application URLs: Target application endpoints and base URLs
# - File System Paths: Test data, reports, and resource file locations  
# - Browser Configuration: Browser type, headless mode, and automation settings
# - Test Configuration: Logging levels, timeout settings, and test behavior
# - Data Management: Test data files and empty state management
# =============================================================================

*** Variables ***

# APPLICATION CONFIGURATION
# URLs and endpoints for the target application under test
${URL_SITE}              https://www.saucedemo.com/    # Base URL for SauceDemo e-commerce application

# FILE SYSTEM PATHS
# Paths to test resources, data files, and project directories
${PATH_FEATURES}         ${EXECDIR}/atests/features    # Root directory for test feature files
${YAML_FILE}             ${EXECDIR}/atests/support/resources/data/mass_of_tests.yaml    # Test data configuration file

# BROWSER CONFIGURATION  
# Settings for browser automation and web driver behavior
${BROWSER}               chromium                      # Browser engine to use (chromium/firefox/webkit)
${HEADLESS_FLAG}         ${False}                     # Run browser in headless mode (True/False)

# TEST CONFIGURATION
# General test execution settings and behavior control
${LOG_LEVEL}             DEBUG                        # Logging level for test execution (TRACE/DEBUG/INFO/WARN/ERROR)
${DIC_EMPTY}                                          # Empty dictionary placeholder for initialization