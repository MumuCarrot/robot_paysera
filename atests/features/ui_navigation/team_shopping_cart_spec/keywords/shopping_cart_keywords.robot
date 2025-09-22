*** Settings ***
# Import base test functionality and shopping cart page elements
Resource     ../../../../support/baseTests.robot    # Common test setup and utilities
Variables    ../elements/shopping_cart_page.yaml    # Shopping cart element locators and test data

# =============================================================================
# Shopping Cart Keywords Library
# 
# This library contains technical keywords for interacting with the shopping cart
# functionality on the SauceDemo application. These keywords handle product selection,
# cart management, item removal, and cart validation operations that support
# comprehensive e-commerce testing scenarios.
#
# Keyword categories:
# - Test Data Management: Setting up and managing test data structures
# - Product Selection: Adding items to cart from inventory page
# - Cart Navigation: Moving between inventory and cart pages  
# - Cart Management: Removing items and managing cart contents
# - Cart Validation: Verifying cart state, contents, and pricing
# - Dynamic Element Handling: Managing product-specific selectors
# =============================================================================

*** Keywords ***
Setting the Data for Testing
    [Documentation]    Initializes empty data structures for tracking cart items during test execution.
    ...                This keyword creates and sets up lists that will store product names and prices
    ...                as items are added to the cart. These data structures are used for validation
    ...                and comparison throughout the test lifecycle.
    ...
    ...                Data structures created:
    ...                - list_names: Stores product names added to cart
    ...                - list_prices: Stores corresponding product prices
    ...                
    ...                Usage: This should be called in Test Setup to ensure clean data state
    @{list_names}=    Create List        # Initialize empty list for product names
    @{list_prices}=    Create List       # Initialize empty list for product prices
    Set Test Variable     @{list_names}   # Make names list available to all test steps
    Set Test Variable     @{list_prices}  # Make prices list available to all test steps

Select Inventory Item by Name
    [Documentation]    Adds specified products to the shopping cart by navigating to each product
    ...                and clicking the "Add to Cart" button. This keyword handles the complete
    ...                product selection workflow including price extraction and navigation.
    ...
    ...                Args:
    ...                    ${names}: Comma-separated string of product names to add to cart
    ...                              Example: "Sauce Labs Bolt T-Shirt, Sauce Labs Fleece Jacket"
    ...
    ...                Process for each product:
    ...                1. Navigate to product detail page
    ...                2. Click "Add to Cart" button (with fallback to dynamic selector)
    ...                3. Extract and store product price
    ...                4. Return to inventory page for next product
    [Arguments]    ${names}
    @{list_names}=   Split String    ${names}    ,                       # Convert comma-separated string to list

    FOR    ${item_name}    IN    @{list_names}                           # Process each product individually
        Set Item in Locator        ${item_name}                         # Set dynamic locator for current product
        Scroll To Element    css=${ITEN_ELEMENT}                        # Scroll to product element for visibility
        Click                css=${ITEN_ELEMENT}                        # Click product name to navigate to detail page
        Wait For All Promises                                           # Wait for page navigation to complete
        
        # Try generic add button first, then fallback to dynamic selector if needed
        ${add_button_visible}=    Run Keyword And Return Status         # Check if generic add button exists
        ...    Wait For Elements State    ${ADD_CART_BUTTON}    state=visible    timeout=5s
        IF    not ${add_button_visible}                                  # If generic button not found
            Set Add to Cart Button for Item    ${item_name}             # Create product-specific selector
            Wait For Elements State    ${ADD_CART_BUTTON_DYNAMIC}    state=visible    timeout=15s  # Wait for dynamic button
            Click                ${ADD_CART_BUTTON_DYNAMIC}             # Click product-specific add button
        ELSE
            Click                ${ADD_CART_BUTTON}                      # Click generic add button
        END
        
        ${price_text}=       Get Text    ${PRICE_DIV}                   # Extract product price from detail page
        Click                ${BACK_PRODUCTS_BUTTON}                    # Return to inventory page
        Wait For All Promises                                           # Wait for navigation to complete
        Append To List       ${list_prices}     ${price_text}          # Store price in test data list
    END
    Set Test Variable     @{list_names}                                 # Update test variable with selected products
    Set Test Variable     @{list_prices}                               # Update test variable with product prices

Select the option to view the items in your cart
    [Documentation]    Navigates from the inventory page to the shopping cart page to view cart contents.
    ...                This keyword handles the complete navigation sequence including waiting for
    ...                the cart page to fully load and become interactive.
    ...
    ...                Navigation process:
    ...                1. Wait for cart button to be visible and clickable
    ...                2. Click cart button to navigate to cart page
    ...                3. Wait for all asynchronous operations to complete
    ...                4. Ensure cart page is fully loaded before proceeding
    Wait For Elements State    ${CART_BUTTON}    state=visible    timeout=10s    # Ensure cart button is available for clicking
    Click    ${CART_BUTTON}                                                       # Navigate to shopping cart page
    Wait For All Promises                                                         # Wait for navigation and async operations
    Wait For Load State    state=networkidle    timeout=10s                      # Ensure cart page is fully loaded

Remove item from cart
    [Documentation]    Removes specified items from the shopping cart and updates the test data structures.
    ...                This keyword handles the complete item removal process including locating
    ...                remove buttons, clicking them, and maintaining data consistency.
    ...
    ...                Args:
    ...                    ${names}: Comma-separated string of product names to remove from cart
    ...                              Example: "Sauce Labs Bolt T-Shirt" or "Product1, Product2"
    ...
    ...                Process for each item:
    ...                1. Locate the remove button for the specific product
    ...                2. Click the remove button to delete item from cart
    ...                3. Update test data lists to reflect the removal
    ...                4. Maintain data consistency between UI and test state
    [Arguments]    ${names}
    @{list_names_remove}=   Split String    ${names}    ,               # Convert comma-separated string to list

    FOR    ${item_name}    IN    @{list_names_remove}                   # Process each item to remove
        Set Item Delete in Locator    ${item_name}                     # Set locator for item's remove button
        Wait For Elements State    ${ITEN_ELEMENT}    state=visible    timeout=10s  # Wait for remove button to be visible
        Scroll To Element    ${ITEN_ELEMENT}                           # Scroll to ensure remove button is in view
        Click    ${ITEN_ELEMENT}                                       # Click remove button to delete item
        
        # Update test data lists to reflect item removal
        ${INDEX}=        Get Index From List    ${list_names}    ${item_name}      # Find index of removed item
        Remove From List     ${list_names}     ${INDEX}                            # Remove item name from tracking list
        Remove From List     ${list_prices}    ${INDEX}                           # Remove corresponding price from tracking list
    END
    
    Wait For All Promises                                              # Wait for all removal operations to complete
    Run Keyword And Ignore Error   Wait For Load State    state=networkidle      # Ensure page updates are complete (ignore if fails)

Validate in Cart
    [Documentation]    Comprehensive validation of shopping cart contents and functionality.
    ...                This keyword verifies that the cart displays correct items, quantities,
    ...                and provides all expected interactive elements for cart management.
    ...
    ...                Validation criteria:
    ...                - All added products are visible in cart
    ...                - Cart control buttons (Checkout, Continue Shopping) are available
    ...                - Each cart item has a corresponding remove button
    ...                - Item quantities match expected values
    ...                - Cart item count matches test data expectations
    Validate the list of elements                                           # Verify product names and prices are displayed
    Wait For Elements State         ${CHECKOUT_BUTTON}   state=visible    timeout=30s        # Ensure checkout button is available
    Wait For Elements State         ${CONTINUE_SHOPPING_BUTTON}   state=visible    timeout=30s  # Ensure continue shopping button is available
    ${elements_delete}=             Get Elements    ${DELETE_BUTTON}:has-text(\"Remove\")    # Count all remove buttons in cart
    ${elements_cart_quantity}=      Get Elements    ${QUATITY_ITEM_TEXT}                     # Count all quantity indicators
    ${delete_count}=                Get Length    ${elements_delete}                         # Get number of remove buttons
    ${cart_quantity_count}=         Get Length    ${elements_cart_quantity}                 # Get number of quantity elements
    ${list_count}=                  Get Length    ${list_names}                             # Get expected number of items from test data
    Should Be Equal       ${list_count}    ${cart_quantity_count}                          # Verify item count matches expectations
    Should Be Equal       ${list_count}    ${delete_count}                                 # Verify each item has a remove button

Validate empty itens in Cart
    [Documentation]    Validates that the shopping cart is in empty state after all items have been removed.
    ...                This keyword verifies that the cart properly handles the empty state and displays
    ...                appropriate UI elements and messaging for an empty cart scenario.
    ...
    ...                Validation approach:
    ...                - Uses shorter timeout to quickly detect empty cart state
    ...                - Reuses standard cart validation logic with adjusted expectations
    ...                - Confirms cart control buttons remain functional even when empty
    Set Browser Timeout    3s              # Set shorter timeout for empty cart validation
    Validate in Cart                       # Reuse standard validation logic (expects empty lists)

Set Item in Locator
    [Documentation]    Creates a dynamic CSS selector for a specific product by name on the inventory page.
    ...                This keyword generates a locator that can find a product element based on its
    ...                display name, enabling flexible product selection during test execution.
    ...
    ...                Args:
    ...                    ${item}: The product name to create a locator for (whitespace will be trimmed)
    ...
    ...                Generated locator:
    ...                - Uses CSS selector with :has-text() to match product name
    ...                - Targets the inventory item name element specifically
    ...                - Handles whitespace automatically by trimming input
    [Arguments]    ${item}
    ${ITEN_ELEMENT}=   Set Variable  div.inventory_item_name:has-text(\"${item.strip()}\")  # Create CSS selector for product name
    Set Suite Variable    ${ITEN_ELEMENT}                                                    # Make locator available to other keywords

Set Add to Cart Button for Item
    [Documentation]    Creates a dynamic selector for the "Add to Cart" button of a specific product.
    ...                This keyword generates a product-specific button selector by normalizing the
    ...                product name to match the expected HTML id format used by the application.
    ...
    ...                Args:
    ...                    ${item_name}: The product name to create a button selector for
    ...
    ...                Normalization process:
    ...                1. Trim whitespace from product name
    ...                2. Replace spaces with hyphens
    ...                3. Convert to lowercase
    ...                4. Create CSS selector using normalized name as id
    ...
    ...                Example: "Sauce Labs Bolt T-Shirt" becomes "add-to-cart-sauce-labs-bolt-t-shirt"
    [Arguments]    ${item_name}
    ${normalized_name}=    Replace String    ${item_name.strip()}    ${SPACE}    -         # Replace spaces with hyphens
    ${normalized_name}=    Convert To Lower Case    ${normalized_name}                     # Convert to lowercase for id matching
    ${ADD_CART_BUTTON_DYNAMIC}=   Set Variable    css=button[id="add-to-cart-${normalized_name}"]  # Create dynamic CSS selector
    Set Suite Variable    ${ADD_CART_BUTTON_DYNAMIC}                                        # Make dynamic selector available globally

Set Item Delete in Locator
    [Documentation]    Creates a dynamic XPath selector for the "Remove" button of a specific cart item.
    ...                This keyword generates a locator that can find the remove button for a product
    ...                by navigating the DOM structure from the product name to its associated remove button.
    ...
    ...                Args:
    ...                    ${item}: The product name to create a remove button locator for
    ...
    ...                XPath strategy:
    ...                1. Find div containing the exact product name
    ...                2. Navigate to ancestor cart item container
    ...                3. Find descendant remove button with "Remove" text
    ...                4. This handles the complex cart DOM structure reliably
    [Arguments]    ${item}
    ${ITEN_ELEMENT}=   Set Variable  xpath=//div[text()="${item.strip()}"]/ancestor::div[@class="cart_item_label"]/descendant::button[text()="Remove"]  # Create XPath for remove button
    Set Suite Variable    ${ITEN_ELEMENT}                                                              # Make locator available globally

Validate the list of elements
    [Documentation]    Validates that all expected products and their prices are visible in the cart.
    ...                This keyword checks both product names and corresponding prices to ensure
    ...                that the cart contents match the test data expectations exactly.
    ...
    ...                Validation process:
    ...                1. Check if there are items to validate (skip if cart should be empty)
    ...                2. For each expected product: verify name is visible in cart
    ...                3. For each expected price: verify price is displayed in cart
    ...                4. Ensure all validations pass before proceeding
    ${list_count}=                  Get Length    ${list_names}              # Get number of items expected in cart
    IF    ${list_count}>0                                                    # Only validate if cart should contain items
        # Validate all product names are visible in cart
        FOR    ${item}    IN    @{list_names}                               # Check each expected product
            Set Item in Locator        ${item}                              # Create locator for current product
            Wait For Elements State    css=${ITEN_ELEMENT}   state=visible    timeout=30s  # Verify product name is displayed
        END
        # Validate all product prices are visible in cart
        FOR    ${price}    IN    @{list_prices}                             # Check each expected price
            Wait For Elements State    text=${price}   state=visible    timeout=30s         # Verify price is displayed
        END
    END