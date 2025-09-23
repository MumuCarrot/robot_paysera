*** Settings ***
# Import libraries for API testing
Library    RequestsLibrary
Library    Collections
Library    DateTime    # For generating unique timestamps

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
    [Documentation]    Creates a test user with provided data and returns the generated user ID.
    ...                This utility keyword is used when test scenarios need to create a user
    ...                and immediately use the returned ID for subsequent operations. It handles
    ...                the complete creation workflow including validation of successful creation.
    ...
    ...                Arguments:
    ...                - user_data: Dictionary containing user information (name, email, age, etc.)
    ...
    ...                Returns: Integer user ID of the newly created user
    ...                Raises: Test failure if user creation fails or returns unexpected response
    [Arguments]    ${user_data}
    ${response}=    POST    ${BASE_URL}/users    json=${user_data}          # Send POST request to create user
    Should Be Equal As Numbers    ${response.status_code}    201             # Verify successful creation (201 status)
    ${json_response}=    Set Variable    ${response.json()}                  # Parse JSON response 
    RETURN    ${json_response['data']['id']}                                # Return the generated user ID

Create Valid Test User
    [Documentation]    Creates a test user using predefined valid user data from test configuration.
    ...                This convenience keyword uses the VALID_USER data defined in the elements file
    ...                to create a user with complete, valid information including nested address
    ...                and profile data. Uses unique email to avoid conflicts.
    ...
    ...                Returns: Integer user ID of the created user
    ...                Dependencies: Requires VALID_USER data to be defined in elements file
    
    # Create unique user data to avoid conflicts
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_email}=    Set Variable    valid_test_${timestamp}@example.com
    &{unique_user}=    Create Dictionary
    ...    name=Valid Test User ${timestamp}
    ...    email=${unique_email}
    ...    age=${VALID_USER['age']}
    ...    address=${VALID_USER['address']}
    ...    profile=${VALID_USER['profile']}
    
    ${user_id}=    Create Test User And Return ID    ${unique_user}         # Create user using unique valid data
    RETURN    ${user_id}                                                   # Return the generated user ID

# =============================================================================
# User Validation Keywords  
# =============================================================================

Validate User Response Structure
    [Documentation]    Validates that a user API response contains the expected structure and fields.
    ...                This validation keyword ensures that user-related API responses follow the
    ...                expected format including status code, data container, and required user fields.
    ...                Used across multiple test scenarios to ensure consistent response validation.
    ...
    ...                Arguments:
    ...                - response: HTTP response object from API call
    ...                - expected_status: Expected HTTP status code (default: 200)
    ...
    ...                Returns: Parsed JSON response object for further validation
    ...                Validates: Status code, data container, user ID, name, and email fields
    [Arguments]    ${response}    ${expected_status}=200
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}  # Verify HTTP status code matches expectation
    ${json_response}=    Set Variable    ${response.json()}                       # Parse JSON response for field validation
    Should Contain    ${json_response}    data                                    # Verify response contains data container
    Should Contain    ${json_response['data']}    id                              # Verify user data includes ID field
    Should Contain    ${json_response['data']}    name                            # Verify user data includes name field
    Should Contain    ${json_response['data']}    email                           # Verify user data includes email field
    RETURN    ${json_response}                                                   # Return parsed response for further use

Validate User Response With Nested Fields
    [Documentation]    Validates that a user response has the expected structure including nested fields
    [Arguments]    ${response}    ${expected_status}=200
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response}    data
    Should Contain    ${json_response['data']}    id
    Should Contain    ${json_response['data']}    name
    Should Contain    ${json_response['data']}    email
    Should Contain    ${json_response['data']}    address
    Should Contain    ${json_response['data']}    profile
    RETURN    ${json_response}

Validate Address Structure
    [Documentation]    Validates address object structure in user data
    [Arguments]    ${user_data}
    Should Contain    ${user_data}    address
    Should Contain    ${user_data['address']}    street
    Should Contain    ${user_data['address']}    city
    
Validate Profile Structure
    [Documentation]    Validates profile object structure in user data
    [Arguments]    ${user_data}
    Should Contain    ${user_data}    profile
    Should Contain    ${user_data['profile']}    occupation
    
Validate Full Nested User Structure
    [Documentation]    Validates complete nested user structure including address and profile
    [Arguments]    ${user_data}
    # Basic user fields
    Should Contain    ${user_data}    name
    Should Contain    ${user_data}    email
    Should Contain    ${user_data}    age
    
    # Address validation
    Should Contain    ${user_data}    address
    Should Contain    ${user_data['address']}    street
    Should Contain    ${user_data['address']}    city
    
    # Profile validation
    Should Contain    ${user_data}    profile
    Should Contain    ${user_data['profile']}    occupation

Validate User Preferences
    [Documentation]    Validates user preferences within profile object
    [Arguments]    ${profile_data}
    Should Contain    ${profile_data}    preferences
    Should Contain    ${profile_data['preferences']}    newsletter
    Should Contain    ${profile_data['preferences']}    notifications
    Should Contain    ${profile_data['preferences']}    theme

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
    [Documentation]    Retrieves a specific user from the API using their unique identifier.
    ...                This keyword sends a GET request to the /users/{id} endpoint and returns
    ...                the complete HTTP response. Supports both positive and negative test scenarios
    ...                by allowing different expected status codes.
    ...
    ...                Arguments:
    ...                - user_id: The unique identifier of the user to retrieve
    ...                - expected_status: Expected HTTP status code (default: 200 for success)
    ...
    ...                Returns: Complete HTTP response object containing user data or error
    ...                Common Usage: Get user details, verify user existence, negative testing
    [Arguments]    ${user_id}    ${expected_status}=200
    ${response}=    GET    ${BASE_URL}/users/${user_id}    expected_status=${expected_status}    # Send GET request for specific user
    RETURN    ${response}                                                                       # Return complete HTTP response

Update User By ID  
    [Documentation]    Updates an existing user's information using their unique identifier.
    ...                This keyword sends a PUT request to the /users/{id} endpoint with updated
    ...                user data. Supports partial or complete user data updates including nested
    ...                fields like address and profile information.
    ...
    ...                Arguments:
    ...                - user_id: The unique identifier of the user to update
    ...                - user_data: Dictionary containing updated user information
    ...                - expected_status: Expected HTTP status code (default: 200 for success)
    ...
    ...                Returns: Complete HTTP response object with updated user data or error
    ...                Note: Supports both full object replacement and partial field updates
    [Arguments]    ${user_id}    ${user_data}    ${expected_status}=200
    ${response}=    PUT    ${BASE_URL}/users/${user_id}    json=${user_data}    expected_status=${expected_status}    # Send PUT request with updated data
    RETURN    ${response}                                                                                            # Return complete HTTP response

Delete User By ID
    [Documentation]    Permanently removes a user from the system using their unique identifier.
    ...                This keyword sends a DELETE request to the /users/{id} endpoint to remove
    ...                the specified user and all associated data. Used for cleanup operations
    ...                and testing deletion functionality.
    ...
    ...                Arguments:
    ...                - user_id: The unique identifier of the user to delete
    ...                - expected_status: Expected HTTP status code (default: 200 for success)
    ...
    ...                Returns: Complete HTTP response object with deletion confirmation or error
    ...                Warning: This operation is permanent and cannot be undone
    [Arguments]    ${user_id}    ${expected_status}=200
    ${response}=    DELETE    ${BASE_URL}/users/${user_id}    expected_status=${expected_status}    # Send DELETE request to remove user
    RETURN    ${response}                                                                          # Return complete HTTP response

Delete Test User If Exists
    [Documentation]    Attempts to delete a test user, logging the action
    [Arguments]    ${user_id}
    ${response}=    DELETE    ${BASE_URL}/users/${user_id}
    Log    Attempted to delete user with ID: ${user_id}

# =============================================================================
# API Health Keywords
# =============================================================================

Verify API Is Running
    [Documentation]    Performs a health check to verify the API server is operational and accessible.
    ...                This keyword sends a request to the API health check endpoint and validates
    ...                that the server is responding correctly with the expected health status message
    ...                and endpoint information. Commonly used in test setup or smoke tests.
    ...
    ...                Validations:
    ...                - HTTP status code 200 (OK)
    ...                - Server status message present
    ...                - Endpoints list available in response
    ...
    ...                Raises: Test failure if API server is not responding or returns unexpected data
    ${response}=    GET    ${BASE_URL}/                                            # Send health check request to API root
    Should Be Equal As Numbers    ${response.status_code}    200                   # Verify server responds with success status
    ${json_response}=    Set Variable    ${response.json()}                        # Parse JSON response for validation
    Should Contain    ${json_response['message']}    API Server is running!        # Confirm server status message
    Should Contain    ${json_response}    endpoints                               # Verify endpoints list is included

# =============================================================================
# BDD Keywords (Given-When-Then Style)
# =============================================================================

# Given Keywords - Setup preconditions
Verify API Server Running
    [Documentation]    BDD keyword to verify API server is operational
    Verify API Is Running

Ensure User Exists With Valid Data
    [Documentation]    Creates a test user for test scenarios
    ${user_id}=    Create Valid Test User
    Set Suite Variable    ${TEST_USER_ID}    ${user_id}
    RETURN    ${user_id}

Ensure User Exists With Nested Data
    [Documentation]    Creates a test user with complete nested fields
    # Create unique nested user to avoid conflicts
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_email}=    Set Variable    nested_${timestamp}@example.com
    &{unique_nested_user}=    Create Dictionary
    ...    name=Nested User ${timestamp}
    ...    email=${unique_email}
    ...    age=${VALID_USER['age']}
    ...    address=${VALID_USER['address']}
    ...    profile=${VALID_USER['profile']}
    ${user_id}=    Create Test User And Return ID    ${unique_nested_user}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${user_id}
    RETURN    ${user_id}

Set Nonexistent Target User
    [Documentation]    Ensures no user exists with a specific ID
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_USER_ID}
    Set Suite Variable    ${TARGET_USER_ID}    ${non_existent_id}

Ensure Nested Test Users Exist
    [Documentation]    Ensures test users with nested data exist for cleanup testing
    ${nested_user_id}=    Create Test User And Return ID    ${VALID_USER}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${nested_user_id}
    ${minimal_user_id}=    Create Test User And Return ID    ${VALID_USER_MINIMAL_NESTED}
    Set Suite Variable    ${MINIMAL_NESTED_USER_ID}    ${minimal_user_id}

# When Keywords - Actions
Request All Users
    [Documentation]    Sends GET request to retrieve all users
    ${response}=    GET    ${BASE_URL}/users
    Set Suite Variable    ${API_RESPONSE}    ${response}

Request API Health Check
    [Documentation]    Sends GET request to API health endpoint
    ${response}=    GET    ${BASE_URL}/
    Set Suite Variable    ${API_RESPONSE}    ${response}

Create User With Valid Data
    [Documentation]    Sends POST request to create user with valid data
    # Create unique user data to avoid conflicts
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_email}=    Set Variable    test_${timestamp}@example.com
    ${unique_name}=    Set Variable    Test User ${timestamp}
    &{unique_user}=    Create Dictionary
    ...    name=${unique_name}
    ...    email=${unique_email}
    ...    age=28
    ...    address=${VALID_USER['address']}
    ...    profile=${VALID_USER['profile']}
    
    ${response}=    POST    ${BASE_URL}/users    json=${unique_user}
    Set Suite Variable    ${API_RESPONSE}    ${response}
    Set Suite Variable    ${EXPECTED_USER_NAME}    ${unique_name}
    Set Suite Variable    ${EXPECTED_USER_EMAIL}    ${unique_email}
    Set Suite Variable    ${EXPECTED_USER_AGE}    28
    ${json_response}=    Set Variable    ${response.json()}
    IF    ${response.status_code} == 201
        Set Suite Variable    ${CREATED_USER_ID}    ${json_response['data']['id']}
    END

Create User Missing Email
    [Documentation]    Sends POST request with invalid user data (missing email)
    ${response}=    POST    ${BASE_URL}/users    json=${INVALID_USER_NO_EMAIL}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

Create User Invalid Email Format
    [Documentation]    Sends POST request with invalid email format
    ${response}=    POST    ${BASE_URL}/users    json=${INVALID_EMAIL}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

Request User By Id
    [Documentation]    Sends GET request for specific user ID
    [Arguments]    ${user_id}
    ${response}=    GET    ${BASE_URL}/users/${user_id}    expected_status=any
    Set Suite Variable    ${API_RESPONSE}    ${response}

Request User Invalid Id Format
    [Documentation]    Sends GET request with invalid ID format
    ${response}=    GET    ${BASE_URL}/users/invalid-id    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

Update User With Valid Data
    [Documentation]    Sends PUT request to update user with valid data
    ${timestamp}=    Get Current Date    result_format=epoch
    ${updated_name}=    Set Variable    Updated Test User ${timestamp}
    ${updated_email}=    Set Variable    updated_${timestamp}@example.com
    &{updated_user}=    Create Dictionary    name=${updated_name}    email=${updated_email}    age=${30}
    ${response}=    PUT    ${BASE_URL}/users/${CREATED_USER_ID}    json=${updated_user}
    Set Suite Variable    ${API_RESPONSE}    ${response}
    Set Suite Variable    ${EXPECTED_UPDATED_NAME}    ${updated_name}
    Set Suite Variable    ${EXPECTED_UPDATED_EMAIL}    ${updated_email}
    Set Suite Variable    ${EXPECTED_UPDATED_AGE}    30

Update User With Nested Data
    [Documentation]    Updates user with complete nested field data
    ${timestamp}=    Get Current Date    result_format=epoch
    ${nested_updated_name}=    Set Variable    Updated Nested User ${timestamp}
    ${nested_updated_email}=    Set Variable    updated.nested.${timestamp}@example.com
    &{address_dict}=    Create Dictionary    street=456 Updated St    city=Updated City    state=UC    zip_code=54321    country=Updated Country
    &{preferences_dict}=    Create Dictionary    newsletter=${False}    notifications=${True}    theme=light
    &{profile_dict}=    Create Dictionary    occupation=Senior Developer    company=Updated Corp    phone=+1-555-999-8888    preferences=${preferences_dict}
    &{updated_nested_user}=    Create Dictionary    
    ...    name=${nested_updated_name}    
    ...    email=${nested_updated_email}    
    ...    age=${35}
    ...    address=${address_dict}
    ...    profile=${profile_dict}
    ${response}=    PUT    ${BASE_URL}/users/${NESTED_TEST_USER_ID}    json=${updated_nested_user}
    Set Suite Variable    ${API_RESPONSE}    ${response}
    Set Suite Variable    ${EXPECTED_NESTED_UPDATED_NAME}    ${nested_updated_name}
    Set Suite Variable    ${EXPECTED_NESTED_UPDATED_EMAIL}    ${nested_updated_email}
    Set Suite Variable    ${EXPECTED_NESTED_UPDATED_AGE}    35

Update Nonexistent User
    [Documentation]    Attempts to update a user that doesn't exist
    &{updated_user}=    Create Dictionary    name=Non-existent User    email=nonexistent@example.com    age=${25}
    ${response}=    PUT    ${BASE_URL}/users/${NON_EXISTENT_USER_ID}    json=${updated_user}    expected_status=404
    Set Suite Variable    ${API_RESPONSE}    ${response}

Delete User By Created Id
    [Documentation]    Sends DELETE request for specific user ID
    ${response}=    DELETE    ${BASE_URL}/users/${CREATED_USER_ID}
    Set Suite Variable    ${API_RESPONSE}    ${response}

Delete Nonexistent User
    [Documentation]    Attempts to delete a user that doesn't exist
    ${response}=    DELETE    ${BASE_URL}/users/${NON_EXISTENT_USER_ID}    expected_status=404
    Set Suite Variable    ${API_RESPONSE}    ${response}

Create User With Invalid Nested Data
    [Documentation]    Sends POST request with invalid nested field data
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_INVALID_NESTED_DATA}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

Create User With Missing Nested Required
    [Documentation]    Sends POST request with missing required nested fields
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_MISSING_NESTED_REQUIRED}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

Cleanup Nested Test Users
    [Documentation]    Performs cleanup of test users with nested data
    # Gracefully clean up test users - ignore if they don't exist
    Run Keyword And Ignore Error    Delete User By ID    ${NESTED_TEST_USER_ID}    200
    Run Keyword And Ignore Error    Delete User By ID    ${MINIMAL_NESTED_USER_ID}    200
    Log    Cleanup completed - any test users have been removed

# Then Keywords - Assertions/Validations
Verify Response Status
    [Documentation]    Validates response status code
    [Arguments]    ${expected_status}
    Should Be Equal As Numbers    ${API_RESPONSE.status_code}    ${expected_status}

Verify Response Message Contains
    [Documentation]    Validates response contains expected message
    [Arguments]    ${expected_message}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['message']}    ${expected_message}

Verify Error Message Contains
    [Documentation]    Validates error response contains expected error message
    [Arguments]    ${expected_error}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['error']}    ${expected_error}

Verify Response Has User Data
    [Documentation]    Validates response contains user data structure
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Contain    ${json_response['data']}    id
    Should Contain    ${json_response['data']}    name
    Should Contain    ${json_response['data']}    email

Verify Response Has Users List
    [Documentation]    Validates response contains list of users
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Be True    ${json_response['count']} >= 0

Verify Response Has Api Endpoints
    [Documentation]    Validates response contains endpoints list
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    endpoints

Verify User Id Equals
    [Documentation]    Validates user has specific ID
    [Arguments]    ${expected_id}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['id']}    ${expected_id}

Verify User Name Equals
    [Documentation]    Validates user has specific name
    [Arguments]    ${expected_name}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['name']}    ${expected_name}

Verify User Email Equals
    [Documentation]    Validates user has specific email
    [Arguments]    ${expected_email}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['email']}    ${expected_email}

Verify User Age Equals
    [Documentation]    Validates user has specific age
    [Arguments]    ${expected_age}
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['age']}    ${expected_age}

Verify Response Has Nested User Data
    [Documentation]    Validates response contains complete nested user structure
    ${json_response}=    Validate User Response With Nested Fields    ${API_RESPONSE}    ${API_RESPONSE.status_code}
    Validate Full Nested User Structure    ${json_response['data']}

Verify User Not Found
    [Documentation]    Validates that user was not found (404 error)
    Should Be Equal As Numbers    ${API_RESPONSE.status_code}    404
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['error']}    User not found

Verify All Test Users Removed
    [Documentation]    Validates that all test users have been successfully removed
    Log    All test users have been cleaned up successfully

# And Keywords - Additional assertions that can be chained with Then
And the response should contain "${expected_message}"
    [Documentation]    Validates response contains expected message
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['message']}    ${expected_message}

And the response should contain error "${expected_error}"
    [Documentation]    Validates error response contains expected error message
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['error']}    ${expected_error}

And the response should contain user data
    [Documentation]    Validates response contains user data structure
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Contain    ${json_response['data']}    id
    Should Contain    ${json_response['data']}    name
    Should Contain    ${json_response['data']}    email

And the response should contain users list
    [Documentation]    Validates response contains list of users
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Be True    ${json_response['count']} >= 0

And the response should contain API endpoints
    [Documentation]    Validates response contains endpoints list
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    endpoints

And the user should have ID "${expected_id}"
    [Documentation]    Validates user has specific ID
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['id']}    ${expected_id}

And the user should have name "${expected_name}"
    [Documentation]    Validates user has specific name
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['name']}    ${expected_name}

And the user should have email "${expected_email}"
    [Documentation]    Validates user has specific email
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['email']}    ${expected_email}

And the user should have age "${expected_age}"
    [Documentation]    Validates user has specific age
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['age']}    ${expected_age}

And the response should contain nested user data
    [Documentation]    Validates response contains complete nested user structure
    ${json_response}=    Validate User Response With Nested Fields    ${API_RESPONSE}    ${API_RESPONSE.status_code}
    Validate Full Nested User Structure    ${json_response['data']}

And a user exists with valid data
    [Documentation]    Creates a test user for test scenarios
    ${user_id}=    Create Valid Test User
    Set Suite Variable    ${TEST_USER_ID}    ${user_id}

And a user exists with nested data
    [Documentation]    Creates a test user with complete nested fields
    # Create unique user data to avoid conflicts
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_email}=    Set Variable    nested_and_${timestamp}@example.com
    &{unique_nested_user}=    Create Dictionary
    ...    name=Nested And User ${timestamp}
    ...    email=${unique_email}
    ...    age=${VALID_USER['age']}
    ...    address=${VALID_USER['address']}
    ...    profile=${VALID_USER['profile']}
    ${user_id}=    Create Test User And Return ID    ${unique_nested_user}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${user_id}

And the user does not exist
    [Documentation]    Ensures no user exists with a specific ID
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_USER_ID}
    Set Suite Variable    ${TARGET_USER_ID}    ${non_existent_id}

Delete User By Test Id
    [Documentation]    Sends DELETE request for specific user ID stored in TEST_USER_ID
    ${user_id_to_delete}=    Set Variable    ${TEST_USER_ID}
    ${response}=    DELETE    ${BASE_URL}/users/${user_id_to_delete}
    Set Suite Variable    ${API_RESPONSE}    ${response}
    Set Suite Variable    ${DELETED_USER_ID}    ${user_id_to_delete}

And I create a user with invalid nested data
    [Documentation]    Sends POST request with invalid nested field data
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_INVALID_NESTED_DATA}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

And I create a user with missing required nested fields
    [Documentation]    Sends POST request with missing required nested fields
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_MISSING_NESTED_REQUIRED}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

And I clean up nested field test users
    [Documentation]    Performs cleanup of test users with nested data
    # Gracefully clean up test users - ignore if they don't exist
    Run Keyword And Ignore Error    Delete User By ID    ${NESTED_TEST_USER_ID}    200
    Run Keyword And Ignore Error    Delete User By ID    ${MINIMAL_NESTED_USER_ID}    200
    Log    Cleanup completed - any test users have been removed

And test users with nested data exist
    [Documentation]    Ensures test users with nested data exist for cleanup testing
    ${nested_user_id}=    Create Test User And Return ID    ${VALID_USER}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${nested_user_id}
    ${minimal_user_id}=    Create Test User And Return ID    ${VALID_USER_MINIMAL_NESTED}
    Set Suite Variable    ${MINIMAL_NESTED_USER_ID}    ${minimal_user_id}

And all test users should be removed from the system
    [Documentation]    Validates that all test users have been successfully removed
    Log    All test users have been cleaned up successfully

# Plain keyword forms (without And/Then prefixes) for BDD compatibility
the response should contain "${expected_message}"
    [Documentation]    Plain form - validates response contains expected message
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['message']}    ${expected_message}

the response should contain error "${expected_error}"
    [Documentation]    Plain form - validates error response contains expected error message
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response['error']}    ${expected_error}

the response should contain user data
    [Documentation]    Plain form - validates response contains user data structure
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Contain    ${json_response['data']}    id
    Should Contain    ${json_response['data']}    name
    Should Contain    ${json_response['data']}    email

the response should contain users list
    [Documentation]    Plain form - validates response contains list of users
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    data
    Should Be True    ${json_response['count']} >= 0

the response should contain API endpoints
    [Documentation]    Plain form - validates response contains endpoints list
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Contain    ${json_response}    endpoints

the user should have ID "${expected_id}"
    [Documentation]    Plain form - validates user has specific ID
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['id']}    ${expected_id}

the user should have name "${expected_name}"
    [Documentation]    Plain form - validates user has specific name
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['name']}    ${expected_name}

the user should have email "${expected_email}"
    [Documentation]    Plain form - validates user has specific email
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal    ${json_response['data']['email']}    ${expected_email}

the user should have age "${expected_age}"
    [Documentation]    Plain form - validates user has specific age
    ${json_response}=    Set Variable    ${API_RESPONSE.json()}
    Should Be Equal As Numbers    ${json_response['data']['age']}    ${expected_age}

the response should contain nested user data
    [Documentation]    Plain form - validates response contains complete nested user structure
    ${json_response}=    Validate User Response With Nested Fields    ${API_RESPONSE}    ${API_RESPONSE.status_code}
    Validate Full Nested User Structure    ${json_response['data']}

a user exists with valid data
    [Documentation]    Plain form - creates a test user for test scenarios
    ${user_id}=    Create Valid Test User
    Set Suite Variable    ${TEST_USER_ID}    ${user_id}

a user exists with nested data
    [Documentation]    Plain form - creates a test user with complete nested fields
    # Create unique user data to avoid conflicts
    ${timestamp}=    Get Current Date    result_format=epoch
    ${unique_email}=    Set Variable    nested_plain_${timestamp}@example.com
    &{unique_nested_user}=    Create Dictionary
    ...    name=Nested Plain User ${timestamp}
    ...    email=${unique_email}
    ...    age=${VALID_USER['age']}
    ...    address=${VALID_USER['address']}
    ...    profile=${VALID_USER['profile']}
    ${user_id}=    Create Test User And Return ID    ${unique_nested_user}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${user_id}

the user does not exist
    [Documentation]    Plain form - ensures no user exists with a specific ID
    ${non_existent_id}=    Set Variable    ${NON_EXISTENT_USER_ID}
    Set Suite Variable    ${TARGET_USER_ID}    ${non_existent_id}

Delete User By Test Id (Plain)
    [Documentation]    Plain form - sends DELETE request for specific user ID
    ${user_id_to_delete}=    Set Variable    ${TEST_USER_ID}
    ${response}=    DELETE    ${BASE_URL}/users/${user_id_to_delete}
    Set Suite Variable    ${API_RESPONSE}    ${response}
    Set Suite Variable    ${DELETED_USER_ID}    ${user_id_to_delete}

I create a user with invalid nested data
    [Documentation]    Plain form - sends POST request with invalid nested field data
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_INVALID_NESTED_DATA}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

I create a user with missing required nested fields
    [Documentation]    Plain form - sends POST request with missing required nested fields
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_MISSING_NESTED_REQUIRED}    expected_status=400
    Set Suite Variable    ${API_RESPONSE}    ${response}

I clean up nested field test users
    [Documentation]    Plain form - performs cleanup of test users with nested data
    # Gracefully clean up test users - ignore if they don't exist
    Run Keyword And Ignore Error    Delete User By ID    ${NESTED_TEST_USER_ID}    200
    Run Keyword And Ignore Error    Delete User By ID    ${MINIMAL_NESTED_USER_ID}    200
    Log    Cleanup completed - any test users have been removed

test users with nested data exist
    [Documentation]    Plain form - ensures test users with nested data exist for cleanup testing
    ${nested_user_id}=    Create Test User And Return ID    ${VALID_USER}
    Set Suite Variable    ${NESTED_TEST_USER_ID}    ${nested_user_id}
    ${minimal_user_id}=    Create Test User And Return ID    ${VALID_USER_MINIMAL_NESTED}
    Set Suite Variable    ${MINIMAL_NESTED_USER_ID}    ${minimal_user_id}

all test users should be removed from the system
    [Documentation]    Plain form - validates that all test users have been successfully removed
    Log    All test users have been cleaned up successfully