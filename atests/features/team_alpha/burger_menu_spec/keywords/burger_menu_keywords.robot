*** Settings ***
# Import required libraries for browser automation and built-in functionality
Library      Browser     # Playwright browser automation library
Library      BuiltIn     # Robot Framework built-in library

# Import base test functionality, team variables, and burger menu page elements
Resource     ../../../../support/baseTests.robot    # Common test setup and utilities
Resource     ../../team_alpha_variables.robot       # Team Alpha specific variables and configuration
Variables    ../elements/burger_menu_page.yaml      # Burger menu element locators and test data

# =============================================================================
# Burger Menu Keywords Library
# 
# This library contains low-level technical keywords for interacting with the
# burger menu (hamburger menu) component on the SauceDemo application. These
# keywords provide the technical implementation that supports the higher-level
# business-readable test steps.
#
# Keyword categories:
# - Menu State Management: Open, close, and state verification
# - Menu Item Interaction: Clicking and navigation through menu options
# - Validation Keywords: Verifying menu visibility, text content, and behavior
# - Navigation Support: Multi-page navigation and URL validation
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

Open Burger Menu
    [Documentation]    Opens the burger menu by clicking the hamburger button and waits for menu to become visible.
    ...                This keyword handles the complete menu opening sequence including waiting for animations
    ...                and ensuring the menu container is fully loaded and ready for interaction.
    ...
    ...                Expected behavior:
    ...                - Hamburger button is clickable and visible
    ...                - Menu container slides in/appears after click
    ...                - All asynchronous animations complete
    ...                - Menu is fully visible and interactive
    Wait For Elements State    ${BURGER_MENU_BUTTON}    state=visible    timeout=10s    # Ensure hamburger button is available
    Click    ${BURGER_MENU_BUTTON}                                                        # Click to trigger menu opening
    Wait For All Promises                                                                 # Wait for animations/async operations
    Wait For Elements State    ${BURGER_MENU_CONTAINER}    state=visible    timeout=10s  # Confirm menu is fully visible

Close Burger Menu
    [Documentation]    Closes the burger menu using the cross (X) button and waits for menu to hide.
    ...                This is the primary method for closing the menu and handles the complete
    ...                closing sequence including animations and state transitions.
    ...
    ...                Expected behavior:
    ...                - Cross button is visible and clickable
    ...                - Menu container slides out/hides after click
    ...                - All animations complete smoothly
    ...                - Menu is completely hidden from view
    Wait For Elements State    ${BURGER_MENU_CROSS_BUTTON}    state=visible    timeout=10s  # Ensure cross button is available
    Click    ${BURGER_MENU_CROSS_BUTTON}                                                    # Click to trigger menu closing
    Wait For All Promises                                                                   # Wait for animations/async operations
    Wait For Elements State    ${BURGER_MENU_CONTAINER}    state=hidden    timeout=10s     # Confirm menu is fully hidden

Verify Burger Menu Is Open
    [Documentation]    Comprehensive verification that the burger menu is in open state with all elements visible.
    ...                This keyword checks multiple indicators to ensure the menu is not only visible but
    ...                also fully functional and ready for user interaction.
    ...
    ...                Verification criteria:
    ...                - Menu container is visible and accessible
    ...                - Menu state indicator shows "open" status
    ...                - All menu items are visible and clickable
    ...                - No UI elements are cut off or partially hidden
    Wait For Elements State    ${BURGER_MENU_CONTAINER}    state=visible    timeout=10s  # Verify main menu container is visible
    Wait For Elements State    ${MENU_OPEN_STATE}    state=visible    timeout=10s       # Verify menu state indicator is "open"
    Wait For Elements State    ${ALL_ITEMS_LINK}    state=visible    timeout=10s        # Verify "All Items" menu option is visible
    Wait For Elements State    ${ABOUT_LINK}    state=visible    timeout=10s            # Verify "About" menu option is visible
    Wait For Elements State    ${LOGOUT_LINK}    state=visible    timeout=10s           # Verify "Logout" menu option is visible  
    Wait For Elements State    ${RESET_APP_LINK}    state=visible    timeout=10s        # Verify "Reset App State" menu option is visible

Verify Burger Menu Is Closed
    [Documentation]    Verifies that the burger menu is in closed state and completely hidden from view.
    ...                This ensures that the menu is not only invisible but also not interfering with
    ...                the main page content and interactions.
    ...
    ...                Verification criteria:
    ...                - Menu container is completely hidden
    ...                - Menu does not cover page content
    ...                - Page is fully interactive without menu interference
    Wait For Elements State    ${BURGER_MENU_CONTAINER}    state=hidden    timeout=10s  # Verify menu container is completely hidden
    # Menu is considered closed when the container is hidden and not overlaying the main content

Click Menu Item
    [Documentation]    Clicks on a specific menu item within the burger menu by name.
    ...                This keyword provides a flexible interface for menu navigation by accepting
    ...                human-readable menu item names and mapping them to the appropriate UI elements.
    ...
    ...                Args:
    ...                    ${item_name}: The display name of the menu item to click
    ...                                   Supported values: "All Items", "About", "Logout", "Reset App State"
    ...
    ...                Behavior:
    ...                - Maps menu item names to corresponding UI elements
    ...                - Handles navigation and page transitions
    ...                - Waits for async operations to complete
    ...                - Fails with clear error message for unknown menu items
    [Arguments]    ${item_name}
    IF    '${item_name}' == 'All Items'           # Navigate back to main inventory/products page
        Click    ${ALL_ITEMS_LINK}
    ELSE IF    '${item_name}' == 'About'         # Navigate to external SauceLabs about page
        Click    ${ABOUT_LINK}
    ELSE IF    '${item_name}' == 'Logout'        # Logout and return to login page
        Click    ${LOGOUT_LINK}
    ELSE IF    '${item_name}' == 'Reset App State'  # Reset application state (clear cart, etc.)
        Click    ${RESET_APP_LINK}
    ELSE                                          # Handle unknown menu items
        Fail    Unknown menu item: ${item_name}   # Provide clear error for invalid menu item names
    END
    Wait For All Promises                         # Ensure all navigation/async operations complete

Verify Menu Item Text
    [Documentation]    Verifies that a specific menu item displays the expected text content.
    ...                This keyword ensures that menu labels are correctly displayed and helps
    ...                catch localization issues or UI rendering problems.
    ...
    ...                Args:
    ...                    ${expected_text}: The expected text content for the menu item
    ...                                      Should match one of the predefined text constants
    ...
    ...                Verification process:
    ...                - Maps expected text to corresponding menu item element
    ...                - Retrieves actual text content from the UI element
    ...                - Validates that actual text contains expected text
    ...                - Fails with clear error for unknown text values
    [Arguments]    ${expected_text}
    IF    '${expected_text}' == '${ALL_ITEMS_TEXT}'        # Verify "All Items" menu item text
        ${text}=    Get Text    ${ALL_ITEMS_LINK}          # Get actual text from All Items link
        Should Contain    ${text}    ${expected_text}      # Validate text content matches expectation
    ELSE IF    '${expected_text}' == '${ABOUT_TEXT}'       # Verify "About" menu item text
        ${text}=    Get Text    ${ABOUT_LINK}              # Get actual text from About link
        Should Contain    ${text}    ${expected_text}      # Validate text content matches expectation
    ELSE IF    '${expected_text}' == '${LOGOUT_TEXT}'      # Verify "Logout" menu item text  
        ${text}=    Get Text    ${LOGOUT_LINK}             # Get actual text from Logout link
        Should Contain    ${text}    ${expected_text}      # Validate text content matches expectation
    ELSE IF    '${expected_text}' == '${RESET_APP_TEXT}'   # Verify "Reset App State" menu item text
        ${text}=    Get Text    ${RESET_APP_LINK}          # Get actual text from Reset App State link
        Should Contain    ${text}    ${expected_text}      # Validate text content matches expectation
    ELSE                                                   # Handle unknown text values
        Fail    Unknown menu text: ${expected_text}        # Provide clear error for invalid text values
    END

Verify All Menu Items Are Visible
    [Documentation]    Verifies that all expected menu items are visible when the burger menu is open.
    ...                This comprehensive check ensures that the menu UI is complete and no items
    ...                are missing, hidden, or cut off due to rendering issues.
    ...
    ...                Menu items verified:
    ...                - All Items: Navigation back to inventory page
    ...                - About: Link to external SauceLabs information page  
    ...                - Logout: User session termination option
    ...                - Reset App State: Application state reset functionality
    Wait For Elements State    ${ALL_ITEMS_LINK}    state=visible    timeout=10s     # Verify "All Items" link is visible
    Wait For Elements State    ${ABOUT_LINK}    state=visible    timeout=10s         # Verify "About" link is visible
    Wait For Elements State    ${LOGOUT_LINK}    state=visible    timeout=10s        # Verify "Logout" link is visible
    Wait For Elements State    ${RESET_APP_LINK}    state=visible    timeout=10s     # Verify "Reset App State" link is visible

Navigate Through All Menu Items
    [Documentation]    Comprehensive navigation test that clicks through all menu items in sequence.
    ...                This keyword demonstrates a complete workflow of menu navigation and helps
    ...                verify that all menu items are functional and lead to expected destinations.
    ...
    ...                Navigation sequence:
    ...                1. Open menu and verify all items are visible
    ...                2. Navigate to "All Items" page and confirm load
    ...                3. Reopen menu and navigate to "About" page
    ...                4. Return to previous page to maintain test state
    ...
    ...                Usage: This is primarily used for comprehensive menu testing scenarios
    Open Burger Menu                                     # Open menu for navigation testing
    Verify All Menu Items Are Visible                   # Confirm all menu options are available
    Click Menu Item    All Items                        # Navigate to inventory page
    Wait For Load State    state=networkidle    timeout=10s  # Wait for page to fully load
    Open Burger Menu                                     # Reopen menu for next navigation
    Click Menu Item    About                            # Navigate to external about page
    Wait For Load State    state=networkidle    timeout=10s  # Wait for external page to load  
    Go Back                                             # Return to previous page to maintain test context

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
    Close Burger Menu                                                                # Click cross button to close menu                                                 # Click overlay area to close menu

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
    ...                Uses extended timeout for external page loading as third-party sites can be slower.
    Wait For Load State    state=networkidle    timeout=${PAGE_LOAD_TIMEOUT}        # Wait for external page to fully load (using configurable timeout)
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
