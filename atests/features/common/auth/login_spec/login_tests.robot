*** Settings ***
# Import login-specific keywords and functions
Resource        keywords/login_keywords.robot

# Configuration for the entire test suite
Suite Setup       Set Log Level    ${LOG_LEVEL}    # Set logging level for debugging
Test Teardown     Steps to Close Browser          # Cleanup browser after each test
Force Tags        login_tests                     # Tag all tests in this suite

# =============================================================================
# Login Tests Suite
# 
# This test suite contains authentication test cases for the SauceDemo website.
# It covers both positive (successful login) and negative (failed login) scenarios
# to ensure the login functionality works correctly and handles errors appropriately.
#
# Test scenarios included:
# - Successful login with valid credentials
# - Login failure with incorrect password
# - Batch execution of negative test cases
# =============================================================================

*** Test Cases ***
Scenario - Successful login testing
    [Documentation]    Verifies that a user can successfully log into the SauceDemo application
    ...                using valid credentials (standard_user/secret_sauce).
    ...                This positive test case ensures the login flow works as expected.
    [Tags]    login_ok    positive_test    smoke_test
    Given You display the Login Page              # Navigate to login page
    When Perform the site authentication          # Enter valid credentials and submit
    Then Validate if the login was successful     # Confirm successful authentication

Scenario - Negative test, test with wrong user password
    [Documentation]    Verifies that login fails when incorrect password is provided.
    ...                This negative test ensures the system properly rejects invalid credentials
    ...                and displays appropriate error messages to the user.
    [Tags]    login_fail    negative_test    security_test
    Given You display the Login Page                                    # Navigate to login page
    When Perform the site authentication    ${USER}    ${INCORRECT_PASSWORD}  # Use valid username but wrong password
    Then Validate if the login was fail                                 # Confirm login failure and error message

Scenario - Run Negative Login Tests
    [Documentation]    Executes multiple negative test scenarios using data-driven testing.
    ...                This test iterates through a collection of invalid username/password
    ...                combinations to ensure the login system properly handles various
    ...                authentication failure scenarios (empty fields, wrong credentials, etc.).
    [Tags]    login_fail    negative_test    data_driven_test    comprehensive_test
    # Iterate through all negative test cases defined in test data
    FOR    ${TEST_NAME}    IN    @{NEGATIVE_TESTS.keys()}
        # Extract test case details from the test data dictionary
        ${CASE}=    Get From Dictionary    ${NEGATIVE_TESTS}    ${TEST_NAME}
        Log    Running negative test case: ${TEST_NAME}                  # Log current test case for debugging
        # Execute individual negative login test with specific credentials
        Run Negative Login Test    ${CASE['username']}    ${CASE['password']}
    END