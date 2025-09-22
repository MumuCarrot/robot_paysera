*** Settings ***
# Import libraries for API testing
Library    RequestsLibrary
Library    Collections

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
    ...                and profile data. Commonly used in test setup or when a test requires
    ...                a guaranteed valid user to exist.
    ...
    ...                Returns: Integer user ID of the created user
    ...                Dependencies: Requires VALID_USER data to be defined in elements file
    ${user_id}=    Create Test User And Return ID    ${VALID_USER}           # Create user using predefined valid data
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
