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

# APPIUM / ANDROID MOBILE WEB CONFIGURATION
# Settings for Android Chrome automation via Appium
${APPIUM_SERVER_URL}     %{APPIUM_SERVER_URL=http://localhost:4723/wd/hub}   # Appium server endpoint
${ANDROID_DEVICE_NAME}   %{ANDROID_DEVICE_NAME=emulator-5554}                 # Device name or UDID
${APPIUM_AUTOMATION}     %{APPIUM_AUTOMATION=UiAutomator2}                    # Appium automationName
${MOBILE_BROWSER}        %{MOBILE_BROWSER=Chrome}                             # Mobile browserName
${CHROMEDRIVER_PATH}     %{CHROMEDRIVER_PATH=C:/Users/okopo4ok/AppData/Roaming/npm/node_modules/chromedriver/lib/chromedriver/chromedriver.exe}
${CHROMEDRIVER_AUTO}     %{CHROMEDRIVER_AUTO=true}                            # Enable chromedriver auto-download (requires Appium flag)

@{ANDROID_OPEN_ARGS}     platformName=Android
...                      deviceName=${ANDROID_DEVICE_NAME}
...                      automationName=${APPIUM_AUTOMATION}
...                      browserName=${MOBILE_BROWSER}
...                      chromedriverAutodownload=${CHROMEDRIVER_AUTO}
...                      appium:chromedriverAutodownload=${CHROMEDRIVER_AUTO}
...                      chromedriverExecutable=${CHROMEDRIVER_PATH}

&{ANDROID_CAPS}         platformName=Android
...                      deviceName=${ANDROID_DEVICE_NAME}
...                      automationName=${APPIUM_AUTOMATION}
...                      browserName=${MOBILE_BROWSER}
...                      chromedriverAutodownload=${CHROMEDRIVER_AUTO}
...                      appium:chromedriverAutodownload=${CHROMEDRIVER_AUTO}
...                      chromedriverExecutable=${CHROMEDRIVER_PATH}