*** Settings ***
# Import base test functionality and page element definitions
Resource     ../../../../support/baseTests.robot      # Base test setup and common keywords
Variables    ../elements/api_tests.yaml            # API tests element locators and test data

# =============================================================================
# API Tests Keywords Library
# 
# This library contains reusable keywords specifically designed for API testing.
# These keywords provide a high-level interface for common API actions and validations,
# supporting both positive and negative test scenarios.
# =============================================================================

*** Keywords ***
# =============================================================================
# User Creation Keywords
# =============================================================================

Create Test User And Return ID
    [Documentation]    Creates a test user and returns the user ID
    [Arguments]    ${user_data}
    ${response}=    POST    ${BASE_URL}/users    json=${user_data}
    Should Be Equal As Numbers    ${response.status_code}    201
    ${json_response}=    Set Variable    ${response.json()}
    RETURN    ${json_response['data']['id']}

Create Valid Test User
    [Documentation]    Creates a valid test user using predefined data
    ${user_id}=    Create Test User And Return ID    ${VALID_USER}
    RETURN    ${user_id}

# =============================================================================
# User Validation Keywords  
# =============================================================================

Validate User Response Structure
    [Documentation]    Validates that a user response has the expected structure
    [Arguments]    ${response}    ${expected_status}=200
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response}    data
    Should Contain    ${json_response['data']}    id
    Should Contain    ${json_response['data']}    name
    Should Contain    ${json_response['data']}    email
    RETURN    ${json_response}

Validate Error Response
    [Documentation]    Validates that an error response has the expected structure
    [Arguments]    ${response}    ${expected_status}    ${expected_error_message}
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response}    error
    Should Contain    ${json_response['error']}    ${expected_error_message}

# =============================================================================
# User Management Keywords
# =============================================================================

Get User By ID
    [Documentation]    Retrieves a user by ID
    [Arguments]    ${user_id}    ${expected_status}=200
    ${response}=    GET    ${BASE_URL}/users/${user_id}    expected_status=${expected_status}
    RETURN    ${response}

Update User By ID  
    [Documentation]    Updates a user by ID
    [Arguments]    ${user_id}    ${user_data}    ${expected_status}=200
    ${response}=    PUT    ${BASE_URL}/users/${user_id}    json=${user_data}    expected_status=${expected_status}
    RETURN    ${response}

Delete User By ID
    [Documentation]    Deletes a user by ID
    [Arguments]    ${user_id}    ${expected_status}=200
    ${response}=    DELETE    ${BASE_URL}/users/${user_id}    expected_status=${expected_status}
    RETURN    ${response}

Delete Test User If Exists
    [Documentation]    Attempts to delete a test user, logging the action
    [Arguments]    ${user_id}
    ${response}=    DELETE    ${BASE_URL}/users/${user_id}
    Log    Attempted to delete user with ID: ${user_id}

# =============================================================================
# API Health Keywords
# =============================================================================

Verify API Is Running
    [Documentation]    Verifies that the API server is responding
    ${response}=    GET    ${BASE_URL}/
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    API Server is running!
    Should Contain    ${json_response}    endpoints
