*** Settings ***
# Import burger menu specific keywords, team variables, and base test functionality
Resource        keywords/ui_burger_menu_keywords.robot   # Burger menu specific keywords and actions
Resource        ../../../support/baseTests.robot      # Base test setup and common functionality
Resource        ../tribe_alpha_variables.robot         # Team Alpha specific variables and configuration

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
