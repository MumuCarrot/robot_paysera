*** Settings ***
Library     Browser                         # Playwright browser automation library
Library     Collections                     # Python collections library for data operations

# Import base test functionality and page element definitions
Resource     ../../../../support/baseTests.robot    # Base test setup and common keywords
Variables    ../elements/ui_auth.yaml            # Login page element locators and test data

# =============================================================================
# Login Keywords Library
# 
# This file contains reusable keywords specifically designed for login functionality
# testing on the SauceDemo application. These keywords provide a high-level interface
# for common login actions and validations, supporting both positive and negative
# test scenarios.
#
# Keywords included:
# - Authentication actions (login with various credentials)
# - Login validation (success and failure scenarios)
# - Page access validation (unauthorized access prevention)
# - Test data handling for negative test cases
# =============================================================================

*** Keywords ***
Perform the site authentication
    [Documentation]    Performs login authentication by filling username and password fields
    ...                and clicking the login button. Supports both default and custom credentials.
    ...
    ...                Args:
    ...                    ${USER_NAME}: Username to enter (defaults to ${USER} from global variables)
    ...                    ${PW}: Password to enter (defaults to ${PASSWORD} from global variables)
    ...
    ...                Usage:
    ...                    Perform the site authentication                           # Uses default credentials
    ...                    Perform the site authentication    admin    wrongpass    # Uses custom credentials
    [Arguments]    ${USER_NAME}=${USER}    ${PW}=${PASSWORD}
    Fill Text    ${USER_INPUT}        ${USER_NAME}    # Enter username into input field
    Fill Text    ${PASSWORD_INPUT}    ${PW}           # Enter password into input field
    Click        ${LOGIN_BUTTON}                      # Submit login form

Validate if the login was successful
    [Documentation]    Validates that login was successful by checking for the presence of
    ...                key elements on the inventory/products page that appear after successful login.
    ...                This includes the "Products" header text and the inventory container.
    ...
    ...                Validation criteria:
    ...                - "Products" text is visible (main page header)
    ...                - Inventory container is visible (product listing area)
    ...                - All asynchronous operations have completed
    Wait For All Promises                                                    # Ensure all async operations complete
    Wait For Elements State    text=Products   state=visible    timeout=30s  # Verify Products page header is visible
    Wait For Elements State    ${INVENTORY_LOCATOR}   state=visible    timeout=30s  # Verify inventory container is loaded

Validate if the login was fail
    [Documentation]    Validates that login failed by checking for the presence of error elements
    ...                and messages displayed on the login page after unsuccessful authentication.
    ...
    ...                Args:
    ...                    ${ERROR_MESSAGE}: Expected error message (defaults to ${ERROR_TEXT})
    ...
    ...                Validation criteria:
    ...                - Error message header is visible
    ...                - Error UI elements are properly displayed
    [Arguments]    ${ERROR_MESSAGE}=${ERROR_TEXT}
    Wait For Elements State    css=h3[data-test='error']   state=visible    timeout=30s  # Wait for error message to appear
    Elements in Login Page Fail                                                          # Validate error UI elements

Elements in Login Page Fail
    [Documentation]    Validates the visual elements that appear on login failure.
    ...                Checks for error icons and ensures the login button remains available
    ...                for retry attempts.
    ...
    ...                Expected behavior on login failure:
    ...                - Two error icons should be displayed (for username and password fields)
    ...                - Login button should remain visible and clickable
    ...                - Error message should be properly formatted
    ${elements_img_error}=         Get Elements    css=${ERROR_IMG}              # Get all error icon elements
    ${img_error_count}=            Get Length    ${elements_img_error}           # Count error icons
    Should Be Equal                "2"    "${img_error_count}"                  # Verify exactly 2 error icons (username/password)
    Wait For Elements State        ${LOGIN_BUTTON}     state=visible    timeout=15s  # Ensure login button is still available

Access the page without authentication 
    [Documentation]    Attempts to access a protected page without prior authentication.
    ...                This keyword is used to test security features and ensure that
    ...                protected pages properly redirect or block unauthorized access.
    ...
    ...                Args:
    ...                    ${URL}: The URL to attempt to access without authentication
    ...
    ...                Usage:
    ...                    Access the page without authentication    ${INVENTORY_URL}
    [Arguments]    ${URL}
    New Context                      # Create new browser context (fresh session, no cookies)
    New Page    ${URL}              # Navigate to the specified URL without logging in
    Wait For Load State    timeout=20s  # Wait for page to fully load

Run Negative Login Test
    [Documentation]    Executes a complete negative login test scenario with provided credentials.
    ...                This is a composite keyword that combines all steps needed to test
    ...                a single negative login case: navigation, authentication attempt, and validation.
    ...
    ...                Args:
    ...                    ${username}: Username to test (can be empty, invalid, or special characters)
    ...                    ${password}: Password to test (can be empty, invalid, or special characters)
    ...
    ...                Flow:
    ...                1. Navigate to login page
    ...                2. Attempt login with provided credentials
    ...                3. Validate that login failed appropriately
    [Arguments]    ${username}    ${password}
    Given You display the Login Page                    # Navigate to login page
    Perform the site authentication    ${username}    ${password}  # Attempt login with test credentials
    Then Validate if the login was fail                # Verify login failure and error handling

Negative login dataset is available
    [Documentation]    Ensures the negative login dataset is loaded and provides case count for logging.
    ${total_cases}=    Get Length    ${NEGATIVE_TESTS}
    Log    Negative login dataset loaded with ${total_cases} cases

Run all negative login tests
    [Documentation]    Iterates over all negative login scenarios and validates each one.
    FOR    ${TEST_NAME}    IN    @{NEGATIVE_TESTS.keys()}
        ${CASE}=    Get From Dictionary    ${NEGATIVE_TESTS}    ${TEST_NAME}
        Log    Running negative test case: ${TEST_NAME}
        Run Negative Login Test    ${CASE['username']}    ${CASE['password']}
        Steps to Close Browser
    END

All negative login tests should be rejected
    [Documentation]    Confirms completion of negative login scenarios; assertions happen per-case.
    Log    All negative login tests executed and validated
