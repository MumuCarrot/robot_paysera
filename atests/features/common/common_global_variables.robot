*** Settings ***
# Common Global Variables for All Tests
# 
# This file contains shared variables that are used across different test suites
# in the Robot Framework project. These variables provide common configuration
# for browser settings, application URLs, and other cross-cutting concerns.
#
# VARIABLE OVERRIDE EXAMPLES:
# 1. Command line variables:
#    robot -v HEADLESS_FLAG:true -v LOG_LEVEL:INFO atests/
# 2. Environment variables:
#    set HEADLESS_FLAG=true && set LOG_LEVEL=INFO && robot atests/
#    export HEADLESS_FLAG=true LOG_LEVEL=INFO && robot atests/ (Linux/Mac)

*** Variables ***

# APPLICATION CONFIGURATION
# URLs and endpoints for the target application under test
${URL_SITE}              https://www.saucedemo.com/    # Base URL for SauceDemo e-commerce application

# BROWSER CONFIGURATION  
# Settings for browser automation shared across all test suites
${BROWSER}               chromium                                              # Browser engine to use (chromium/firefox/webkit)
${HEADLESS_FLAG}         %{HEADLESS_FLAG=${false}}                           # Run browser in headless mode (true/false) - can be overridden via env var
${HEADLESS_MODE}         ${HEADLESS_FLAG}                                    # Alias for backward compatibility

# TEST CONFIGURATION
# General test execution settings and behavior control
${LOG_LEVEL}             %{LOG_LEVEL=DEBUG}                                  # Logging level for test execution - can be overridden via env var