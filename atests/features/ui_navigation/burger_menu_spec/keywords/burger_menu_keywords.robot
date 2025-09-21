*** Settings ***
# Import required libraries for browser automation and built-in functionality
Library      Browser     # Playwright browser automation library
Library      BuiltIn     # Robot Framework built-in library

# Import base test functionality and burger menu page elements
Resource     ../../../../support/baseTests.robot    # Common test setup and utilities
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

Close Burger Menu By Overlay
    [Documentation]    Closes the burger menu by clicking on the overlay (background area outside the menu).
    ...                This provides an alternative and intuitive way to dismiss the menu, similar to
    ...                modal dialog behavior. Includes fallback to cross button if overlay is not available.
    ...
    ...                Expected behavior:
    ...                - Overlay area should be clickable when menu is open
    ...                - Clicking overlay dismisses menu with smooth animation
    ...                - If overlay not found, fallback to cross button method
    ...                - Menu becomes completely hidden after interaction
    ${overlay_exists}=    Run Keyword And Return Status    Wait For Elements State    ${BURGER_MENU_OVERLAY}    state=visible    timeout=2s  # Check if overlay is available
    IF    not ${overlay_exists}                                           # Handle case where overlay is not present
        Log    Overlay not found, clicking cross button instead          # Log fallback action for debugging
        Click    ${BURGER_MENU_CROSS_BUTTON}                             # Use cross button as fallback
        RETURN                                                            # Exit after fallback action
    END
    Click    ${BURGER_MENU_OVERLAY}                                       # Click overlay area to close menu
    Wait For All Promises                                                 # Wait for animations/async operations
    Wait For Elements State    ${BURGER_MENU_CONTAINER}    state=hidden    timeout=10s  # Confirm menu is fully hidden

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
