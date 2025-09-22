*** Settings ***
# Import shopping cart specific keywords and base test functionality
Resource        keywords/shopping_cart_keywords.robot  # Shopping cart specific keywords and actions
Resource        ../../../support/baseTests.robot       # Base test setup and common functionality

# Test suite configuration
Suite Setup       Set Log Level    ${LOG_LEVEL}         # Set logging level for debugging
Test Setup        Setting the Data for Testing         # Initialize test data structures before each test
Test Teardown     Steps to Close Browser               # Cleanup browser after each test

Force Tags    shopping_cart_tests                      # Tag all tests in this suite

# =============================================================================
# Shopping Cart E-commerce Tests Suite
# 
# This test suite covers the shopping cart functionality on the SauceDemo application,
# including adding items to cart, viewing cart contents, and removing items.
# These tests simulate real e-commerce user workflows and validate the cart management
# system's behavior under various scenarios.
#
# Test scenarios included:
# - Adding multiple products to cart and validating cart contents
# - Removing individual items from cart and verifying remaining items
# - Removing all items from cart and validating empty state
# - Cart state management and item persistence across page navigation
#
# Prerequisites:
# - User must be logged in (handled by each test)
# - Tests operate on the main inventory page with available products
# =============================================================================

*** Test Cases ***
Scenario - Shopping cart checkout itens in cart
    [Documentation]    Tests the complete workflow of adding products to cart and validating cart contents.
    ...                This positive test case verifies that users can successfully add multiple items
    ...                to their shopping cart and that the cart displays correct product information,
    ...                quantities, and pricing.
    ...
    ...                Test Flow:
    ...                1. Login to application with valid credentials
    ...                2. Add specified products to cart from inventory page
    ...                3. Navigate to cart page to view added items
    ...                4. Validate that cart contains correct items with proper details
    [Tags]    shopping_cart_ok    cart_addition    positive_test    e_commerce_flow
    Given Successful login testing                              # Authenticate user and navigate to inventory page
    When Select Inventory Item by Name   ${PRODUCTS_ADD}        # Add multiple products to cart by name
    And Select the option to view the items in your cart       # Navigate to shopping cart page
    Then Validate in Cart                                       # Verify cart contains expected items with correct details

Scenario - Shopping cart checkout remove iten in cart
    [Documentation]    Tests the functionality of removing a single item from the shopping cart.
    ...                This test verifies that users can selectively remove products from their cart
    ...                while maintaining other items, and that the cart updates correctly to reflect
    ...                the changes in quantity, pricing, and available actions.
    ...
    ...                Test Flow:
    ...                1. Login and add multiple products to cart
    ...                2. Navigate to cart page to view all items
    ...                3. Remove one specific item from the cart
    ...                4. Validate that remaining items are still present and cart is updated correctly
    [Tags]    shopping_cart_remove    cart_management    partial_removal    functional_test
    Given Successful login testing                              # Authenticate user and navigate to inventory page
    When Select Inventory Item by Name   ${PRODUCTS_ADD}        # Add multiple products to cart
    And Select the option to view the items in your cart       # Navigate to shopping cart page
    And Remove item from cart            ${PRODUCT_TO_REMOVE}  # Remove one specific item from cart
    Then Validate in Cart                                       # Verify remaining items are correct and cart is updated

Scenario - Shopping cart checkout remove all itens in cart
    [Documentation]    Tests the complete cart clearing functionality by removing all items from the cart.
    ...                This test verifies that users can remove all products from their cart and that
    ...                the application properly handles the empty cart state, displaying appropriate
    ...                messages and maintaining correct UI behavior.
    ...
    ...                Test Flow:
    ...                1. Login and add multiple products to cart
    ...                2. Navigate to cart page to view all items
    ...                3. Remove all items from the cart one by one
    ...                4. Validate that cart is empty and displays appropriate empty state
    [Tags]    shopping_cart_remove    cart_management    complete_removal    edge_case_test
    Given Successful login testing                              # Authenticate user and navigate to inventory page
    When Select Inventory Item by Name   ${PRODUCTS_ADD}        # Add multiple products to cart
    And Select the option to view the items in your cart       # Navigate to shopping cart page  
    And Remove item from cart            ${PRODUCTS_TO_REMOVE}    # Remove all items from cart
    Then Validate empty itens in Cart                          # Verify cart is empty and displays correct empty state