*** Settings ***
# Import burger menu specific keywords and base test functionality
Resource        keywords/burger_menu_keywords.robot   # Burger menu specific keywords and actions
Resource        ../../../support/baseTests.robot      # Base test setup and common functionality

# Test suite configuration
Suite Setup       Set Log Level    ${LOG_LEVEL}                      # Set logging level for debugging
Test Setup        Setting the Test Environment for Burger Menu       # Login before each test  
Test Teardown     Steps to Close Browser                             # Cleanup browser after each test

Force Tags    burger_menu_tests                                     # Tag all tests in this suite

# =============================================================================
# Burger Menu Navigation Tests Suite
# 
# This test suite covers the burger menu (hamburger menu) functionality on the
# SauceDemo application. The burger menu is a common UI pattern that provides
# navigation options in a collapsible side menu.
#
# Test scenarios included:
# - Menu opening and closing via different methods (cross button, overlay)
# - Navigation to different pages through menu items
# - Menu item visibility and text validation  
# - Multiple operation sequences to test menu robustness
#
# Prerequisites:
# - User must be logged in (handled by Test Setup)
# - Tests run on the main inventory/products page
# =============================================================================

*** Keywords ***
Setting the Test Environment for Burger Menu
    [Documentation]    Prepares the test environment by logging in to the application.
    ...                This ensures that each burger menu test starts from an authenticated state
    ...                on the main products page where the burger menu is available.
    ...
    ...                Setup flow:
    ...                1. Navigate to login page
    ...                2. Perform authentication with valid credentials
    ...                3. Validate successful login and page load
    You display the Login Page           # Navigate to SauceDemo login page
    Perform the site authentication      # Login with default valid credentials 
    Validate if the login was successful    # Confirm user is authenticated and on products page

*** Test Cases ***
Scenario - Open and close burger menu with cross button
    [Documentation]    Tests the basic open/close functionality of the burger menu using the cross (X) button.
    ...                This verifies that users can access the menu and close it using the dedicated close button,
    ...                which is the primary method for closing the menu.
    ...
    ...                Test Flow:
    ...                1. Verify menu is initially hidden
    ...                2. Open menu using hamburger button
    ...                3. Verify menu and all items are visible
    ...                4. Close menu using cross button
    ...                5. Verify menu is hidden again
    [Tags]    burger_menu_open_close    basic_functionality    smoke_test
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # Click hamburger button to open menu
    Then Burger menu should be visible with all items  # Verify menu opened and items are displayed
    When User closes burger menu with cross button     # Click X button to close menu
    Then Burger menu should be closed                   # Verify menu is hidden again

Scenario - Open and close burger menu with overlay
    [Documentation]    Tests the menu close functionality using the overlay click method.
    ...                This verifies that users can close the menu by clicking outside of it (on the overlay),
    ...                which is an alternative and intuitive way to dismiss modal-like components.
    ...
    ...                Test Flow:
    ...                1. Verify menu is initially hidden
    ...                2. Open menu using hamburger button  
    ...                3. Verify menu and all items are visible
    ...                4. Close menu by clicking on the overlay (outside menu area)
    ...                5. Verify menu is hidden
    [Tags]    burger_menu_overlay    user_experience    alternative_interaction
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # Click hamburger button to open menu
    Then Burger menu should be visible with all items  # Verify menu opened and items are displayed  
    When User closes burger menu by clicking overlay   # Click overlay area to close menu
    Then Burger menu should be closed                   # Verify menu is hidden again

Scenario - Navigate to All Items through burger menu
    [Documentation]    Tests navigation functionality by clicking on the "All Items" menu option.
    ...                This verifies that the menu item correctly navigates back to the main inventory page,
    ...                which is useful when users are on different pages and want to return to the product catalog.
    ...
    ...                Test Flow:
    ...                1. Verify menu is initially hidden
    ...                2. Open burger menu
    ...                3. Click "All Items" menu item
    ...                4. Verify user is redirected to inventory page
    [Tags]    burger_menu_navigation    page_navigation    functional_test
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # Click hamburger button to open menu
    And User clicks on "All Items" menu item          # Click on All Items navigation option
    Then User should be on inventory page               # Verify successful navigation to products page

Scenario - Navigate to About page through burger menu
    [Documentation]    Tests external navigation by clicking on the "About" menu option.
    ...                This verifies that the menu item correctly redirects to the external SauceLabs company page,
    ...                testing the integration between the demo app and the main company website.
    ...
    ...                Test Flow:
    ...                1. Verify menu is initially hidden
    ...                2. Open burger menu
    ...                3. Click "About" menu item
    ...                4. Verify user is redirected to SauceLabs about page
    [Tags]    burger_menu_navigation    external_navigation    integration_test
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # Click hamburger button to open menu  
    And User clicks on "About" menu item               # Click on About navigation option
    Then User should be redirected to about page        # Verify redirect to external SauceLabs site
    
Scenario - Verify all menu items are visible
    [Documentation]    Tests the visibility and content of all menu items when the burger menu is opened.
    ...                This ensures that all expected navigation options are present and display the correct text,
    ...                providing a comprehensive validation of the menu's UI components.
    ...
    ...                Test Flow:
    ...                1. Verify menu is initially hidden
    ...                2. Open burger menu
    ...                3. Verify all expected menu items are visible
    ...                4. Verify all menu items display correct text content
    [Tags]    burger_menu_items    ui_validation    content_verification
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # Click hamburger button to open menu
    Then All menu items should be visible              # Verify all menu options are displayed
    And Menu items should have correct text            # Verify text content of each menu item
    
Scenario - Multiple menu operations
    [Documentation]    Tests the burger menu through multiple open/close cycles using different methods.
    ...                This comprehensive test ensures the menu remains functional and stable after repeated
    ...                operations, testing both close methods (cross button and overlay click) in sequence.
    ...
    ...                Test Flow:
    ...                1. Verify initial closed state
    ...                2. Open menu and verify visibility
    ...                3. Close menu with cross button and verify hidden
    ...                4. Open menu again and verify visibility
    ...                5. Close menu with overlay click and verify hidden
    [Tags]    burger_menu_multiple_ops    comprehensive_test    robustness_test    regression_test
    Given Burger menu should be initially closed        # Verify starting state - menu hidden
    When User opens the burger menu                     # First open: Click hamburger button
    Then Burger menu should be visible with all items  # Verify menu opened and items displayed
    When User closes burger menu with cross button     # First close: Use cross button method
    Then Burger menu should be closed                   # Verify menu is hidden
    When User opens the burger menu again              # Second open: Click hamburger button again
    Then Burger menu should be visible with all items  # Verify menu opened again and items displayed
    When User closes burger menu by clicking overlay   # Second close: Use overlay click method  
    Then Burger menu should be closed                   # Verify menu is hidden again

# =============================================================================
# Test Case Step Keywords
# 
# These keywords represent individual test steps that are composed to create
# complete test scenarios. They provide a business-readable interface that
# hides technical implementation details and maps to user actions and expectations.
# =============================================================================

*** Keywords ***
Burger menu should be initially closed
    [Documentation]    Verifies that the burger menu is in its initial closed state.
    ...                Ensures the hamburger button is visible but the menu itself is hidden.
    Wait For Elements State    ${BURGER_MENU_BUTTON}    state=visible    timeout=10s  # Ensure burger button is available
    Verify Burger Menu Is Closed                                                     # Verify menu is currently hidden

User opens the burger menu
    [Documentation]    Simulates user action of opening the burger menu by clicking the hamburger button.
    Open Burger Menu                                                                 # Click hamburger button to open menu

User opens the burger menu again
    [Documentation]    Simulates user reopening the burger menu after it was previously closed.
    ...                This is used in multi-step scenarios to test menu functionality after state changes.
    Open Burger Menu                                                                 # Click hamburger button to open menu again

Burger menu should be visible with all items
    [Documentation]    Verifies that the burger menu is open and all menu items are properly displayed.
    ...                This validation confirms both the menu visibility and content completeness.
    Verify Burger Menu Is Open                                                       # Verify menu container is visible
    Verify All Menu Items Are Visible                                               # Verify all menu options are displayed

User closes burger menu with cross button
    [Documentation]    Simulates user closing the burger menu using the cross (X) button.
    ...                This tests the primary method for dismissing the menu.
    Close Burger Menu                                                                # Click cross button to close menu

User closes burger menu by clicking overlay
    [Documentation]    Simulates user closing the burger menu by clicking on the overlay area.
    ...                This tests the alternative method for dismissing modal-like components.
    Close Burger Menu By Overlay                                                     # Click overlay area to close menu

Burger menu should be closed
    [Documentation]    Verifies that the burger menu is in closed state and hidden from view.
    Verify Burger Menu Is Closed                                                     # Verify menu is hidden

User clicks on "${item_name}" menu item
    [Documentation]    Simulates user clicking on a specific menu item within the burger menu.
    ...                This keyword supports parameterized menu item selection for flexible navigation testing.
    ...
    ...                Args:
    ...                    ${item_name}: The name of the menu item to click (e.g., "All Items", "About")
    Click Menu Item    ${item_name}                                                  # Click specified menu item

User should be on inventory page
    [Documentation]    Verifies that the user has been successfully navigated to the inventory/products page.
    ...                Validates both page element presence and URL content.
    Wait For Elements State    ${INVENTORY_LOCATOR}    state=visible    timeout=10s  # Wait for inventory container to load
    ${current_url}=    Get Url                                                       # Get current page URL
    Should Contain    ${current_url}    inventory.html                              # Verify URL contains inventory page path

User should be redirected to about page
    [Documentation]    Verifies that the user has been redirected to the external SauceLabs about page.
    ...                Validates successful external navigation and URL redirection.
    Wait For Load State    state=networkidle    timeout=15s                         # Wait for external page to fully load
    ${current_url}=    Get Url                                                       # Get current page URL
    Should Contain    ${current_url}    saucelabs.com                               # Verify URL contains SauceLabs domain
    
All menu items should be visible
    [Documentation]    Verifies that all expected menu items are visible when the menu is open.
    ...                This ensures no menu options are hidden or missing from the UI.
    Verify All Menu Items Are Visible                                               # Check visibility of all menu items

Menu items should have correct text
    [Documentation]    Verifies that all menu items display the expected text content.
    ...                This validates that menu labels are correct and properly localized.
    Verify Menu Item Text    ${ALL_ITEMS_TEXT}                                      # Verify "All Items" text
    Verify Menu Item Text    ${ABOUT_TEXT}                                          # Verify "About" text  
    Verify Menu Item Text    ${LOGOUT_TEXT}                                         # Verify "Logout" text
    Verify Menu Item Text    ${RESET_APP_TEXT}                                      # Verify "Reset App State" text
