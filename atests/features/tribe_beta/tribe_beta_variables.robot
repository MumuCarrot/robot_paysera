*** Settings ***
# Import required libraries for test automation framework
Library        Browser           # Playwright browser automation library for web testing
Library        Collections       # Python collections library for data structure operations  
Library        FakerLibrary      # Library for generating fake/mock test data
Library        String            # Python string manipulation library
Library        allure_robotframework    WITH NAME    Allure    # Allure reporting integration

# =============================================================================
# Team Beta Variables and Configuration
#
# This file contains variables and configuration settings specific to Team Beta
# testing requirements. Team Beta focuses on shopping cart functionality and
# e-commerce workflows within the SauceDemo test automation project.
#
# Team Beta Test Areas:
# - Shopping Cart Management: Add, remove, and validate cart items
# - E-commerce Workflows: Complete purchase flows and cart operations
# - Product Management: Inventory interaction and product selection
#
# Variable Categories:
# - Application URLs: SauceDemo e-commerce application endpoints
# - Shopping Cart Configuration: Cart-specific settings and product data
# - Browser Configuration: Browser settings optimized for e-commerce testing
# - Test Configuration: Team-specific logging and cart testing behavior
# - Product Data: Test products and cart management constants
# =============================================================================


*** Variables ***

# APPLICATION CONFIGURATION
# URLs and endpoints for Team Beta e-commerce testing
${URL_SITE}              https://www.saucedemo.com/    # Base URL for SauceDemo e-commerce application
${INVENTORY_URL}         https://www.saucedemo.com/inventory.html    # Direct link to product inventory page
${CART_URL}              https://www.saucedemo.com/cart.html         # Direct link to shopping cart page

# FILE SYSTEM PATHS
# Paths to test resources, data files, and project directories
${PATH_FEATURES}         ${EXECDIR}/atests/features    # Root directory for test feature files
${YAML_FILE}             ${EXECDIR}/atests/support/resources/data/mass_of_tests.yaml    # Test data configuration file
${CART_YAML_FILE}        ${EXECDIR}/atests/features/team_beta/shopping_cart_spec/elements/shopping_cart_page.yaml    # Shopping cart elements

# SHOPPING CART CONFIGURATION
# Settings and test data for shopping cart functionality
@{PRODUCTS_ADD}          Sauce Labs Backpack    Sauce Labs Bike Light    Sauce Labs Fleece Jacket    # Default products to add to cart
${PRODUCT_TO_REMOVE}     Sauce Labs Bike Light    # Single product to remove in partial removal tests
@{PRODUCTS_TO_REMOVE}    Sauce Labs Backpack    Sauce Labs Bike Light    Sauce Labs Fleece Jacket    # All products to remove in complete removal tests
${CART_TIMEOUT}          15s                      # Default timeout for cart operations
${CHECKOUT_TIMEOUT}      20s                      # Timeout for checkout process

# BROWSER CONFIGURATION  
# Settings for browser automation optimized for e-commerce testing
${BROWSER}               chromium                      # Browser engine to use (chromium/firefox/webkit)
${HEADLESS_FLAG}         %{HEADLESS_FLAG=${false}}                           # Run browser in headless mode (true/false) - can be overridden via env var
${HEADLESS_MODE}         ${HEADLESS_FLAG}                                    # Alias for backward compatibility

# TEST CONFIGURATION
# Team Beta specific test execution settings for shopping cart testing
${LOG_LEVEL}             %{LOG_LEVEL=DEBUG}                                  # Logging level for test execution - can be overridden via env var
${DIC_EMPTY}                                          # Empty dictionary placeholder for initialization

# E-COMMERCE TEST DATA
# Product and pricing constants for validation
${EXPECTED_PRODUCT_COUNT}    6                        # Total number of products available in inventory
${MIN_CART_ITEMS}           1                        # Minimum items for cart validation
${MAX_CART_ITEMS}           6                        # Maximum items that can be added to cart