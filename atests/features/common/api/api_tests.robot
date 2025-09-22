*** Settings ***
# Import required libraries for comprehensive API testing
Library    RequestsLibrary    # HTTP request/response handling for API testing
Library    Collections         # Python collections for data structure manipulation  
Library    String              # String operations and validation utilities
Library    JSONLibrary         # JSON parsing and validation functionality

# Import API-specific keywords and test data
Resource    keywords/api_tests_keywords.robot    # API test keywords and reusable actions

# Suite-level setup and teardown configuration
Suite Setup    Create Session    api    http://localhost:3000    # Initialize HTTP session for API communication
Suite Teardown    Delete All Sessions                            # Clean up all HTTP sessions

*** Test Cases ***
API Health Check
    [Documentation]    Validates that the API server is operational and responding correctly.
    ...                This is a smoke test that should be run first to ensure the API is accessible
    ...                before executing other test scenarios. Verifies both server responsiveness
    ...                and the health check endpoint structure.
    ...
    ...                Expected Response:
    ...                - Status code: 200 (OK)
    ...                - Message: "API Server is running!"
    ...                - Endpoints list present in response
    [Tags]    health    smoke_test    api_foundation
    ${response}=    GET    ${BASE_URL}/                                    # Send GET request to health check endpoint
    Should Be Equal As Numbers    ${response.status_code}    200           # Verify successful response code
    ${json_response}=    Set Variable    ${response.json()}                # Parse JSON response for validation
    Should Contain    ${json_response['message']}    API Server is running!    # Confirm server status message
    Should Contain    ${json_response}    endpoints                       # Verify endpoints list is included

Get All Users - Initial Data
    [Documentation]    Retrieves all users from the database and validates response structure.
    ...                This test verifies the GET /users endpoint functionality and ensures
    ...                that the response contains the expected data structure including user count,
    ...                success message, and data array. Tests the basic user listing functionality
    ...                which is fundamental for user management operations.
    ...
    ...                Expected Response Structure:
    ...                - Status: 200 (OK)
    ...                - Message: "Users retrieved successfully"
    ...                - Count: Number of users (>= 0)
    ...                - Data: Array of user objects
    [Tags]    get_request    user_retrieval    positive_test
    ${response}=    GET    ${BASE_URL}/users                                       # Request all users from database
    Should Be Equal As Numbers    ${response.status_code}    200                   # Verify successful response
    ${json_response}=    Set Variable    ${response.json()}                        # Parse response for validation
    Should Contain    ${json_response['message']}    Users retrieved successfully  # Confirm success message
    Should Be True    ${json_response['count']} >= 0                              # Validate user count is non-negative
    Should Contain    ${json_response}    data                                     # Verify data array exists

Create New User - Valid Data
    [Documentation]    Creates a new user with valid data and validates successful creation.
    ...                This test verifies the POST /users endpoint with complete user data including
    ...                nested fields (address and profile). Validates both the creation process and
    ...                the returned user data structure. The created user ID is stored for use in
    ...                subsequent test cases that require an existing user.
    ...
    ...                Request Data: Uses VALID_USER from test data (includes address and profile)
    ...                Expected Response:
    ...                - Status: 201 (Created) 
    ...                - Message: "User created successfully"
    ...                - Data: Complete user object with generated ID
    [Tags]    post_request    user_creation    positive_test    crud_operation
    ${response}=    POST    ${BASE_URL}/users    json=${VALID_USER}                        # Send POST request with valid user data
    Should Be Equal As Numbers    ${response.status_code}    201                           # Verify creation successful (201)
    ${json_response}=    Set Variable    ${response.json()}                                # Parse response for validation
    Should Contain    ${json_response['message']}    User created successfully             # Confirm success message
    Should Contain    ${json_response['data']}    id                                       # Verify user ID was generated
    Should Be Equal    ${json_response['data']['name']}    Test User                       # Validate name was stored correctly
    Should Be Equal    ${json_response['data']['email']}    test@example.com               # Validate email was stored correctly
    Should Be Equal As Numbers    ${json_response['data']['age']}    28                    # Validate age was stored correctly
    Set Suite Variable    ${CREATED_USER_ID}    ${json_response['data']['id']}             # Store user ID for later tests

Get User By ID - Valid ID
    [Documentation]    Test getting a user by valid ID
    [Tags]    get    users    id
    ${response}=    GET    ${BASE_URL}/users/${CREATED_USER_ID}
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    User retrieved successfully
    Should Be Equal As Numbers    ${json_response['data']['id']}    ${CREATED_USER_ID}
    Should Be Equal    ${json_response['data']['name']}    Test User

Update User - Valid Data
    [Documentation]    Test updating a user with valid data
    [Tags]    put    users    update
    &{updated_user}=    Create Dictionary    name=Updated Test User    email=updated@example.com    age=${30}
    ${response}=    PUT    ${BASE_URL}/users/${CREATED_USER_ID}    json=${updated_user}
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    User updated successfully
    Should Be Equal    ${json_response['data']['name']}    Updated Test User
    Should Be Equal    ${json_response['data']['email']}    updated@example.com
    Should Be Equal As Numbers    ${json_response['data']['age']}    30

Create User - Missing Email (Negative Test)
    [Documentation]    Test creating a user without email should fail
    [Tags]    post    users    negative
    ${response}=    POST    ${BASE_URL}/users    json=${INVALID_USER_NO_EMAIL}    expected_status=400
    Should Be Equal As Numbers    ${response.status_code}    400
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    Name and email are required fields

Create User - Invalid Email Format (Negative Test)
    [Documentation]    Test creating a user with invalid email format should fail
    [Tags]    post    users    negative
    ${response}=    POST    ${BASE_URL}/users    json=${INVALID_EMAIL}    expected_status=400
    Should Be Equal As Numbers    ${response.status_code}    400
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    Invalid email format

Get User By ID - Invalid ID (Negative Test)
    [Documentation]    Test getting a user with non-existent ID
    [Tags]    get    users    negative
    ${response}=    GET    ${BASE_URL}/users/${NON_EXISTENT_USER_ID}    expected_status=404
    Should Be Equal As Numbers    ${response.status_code}    404
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    User not found

Get User By ID - Invalid ID Format (Negative Test)
    [Documentation]    Test getting a user with invalid ID format
    [Tags]    get    users    negative
    ${response}=    GET    ${BASE_URL}/users/invalid-id    expected_status=400
    Should Be Equal As Numbers    ${response.status_code}    400
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    Invalid user ID

Update User - Non-existent ID (Negative Test)
    [Documentation]    Test updating a non-existent user
    [Tags]    put    users    negative
    &{updated_user}=    Create Dictionary    name=Non-existent User    email=nonexistent@example.com    age=${25}
    ${response}=    PUT    ${BASE_URL}/users/${NON_EXISTENT_USER_ID}    json=${updated_user}    expected_status=404
    Should Be Equal As Numbers    ${response.status_code}    404
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    User not found

Delete User - Valid ID
    [Documentation]    Test deleting a user with valid ID
    [Tags]    delete    users
    ${response}=    DELETE    ${BASE_URL}/users/${CREATED_USER_ID}
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    User deleted successfully
    Should Be Equal As Numbers    ${json_response['data']['id']}    ${CREATED_USER_ID}

Delete User - Non-existent ID (Negative Test)
    [Documentation]    Test deleting a non-existent user
    [Tags]    delete    users    negative
    ${response}=    DELETE    ${BASE_URL}/users/${NON_EXISTENT_USER_ID}    expected_status=404
    Should Be Equal As Numbers    ${response.status_code}    404
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    User not found

Verify User Was Deleted
    [Documentation]    Verify that the deleted user cannot be retrieved
    [Tags]    get    users    verification
    ${response}=    GET    ${BASE_URL}/users/${CREATED_USER_ID}    expected_status=404
    Should Be Equal As Numbers    ${response.status_code}    404
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['error']}    User not found

# =============================================================================
# Advanced User Management Tests with Nested Data Structures
#
# This section contains test cases that validate the API's ability to handle
# complex user data with nested objects (address and profile information).
# These tests verify:
# - Creation of users with complete nested data structures
# - Minimal nested data handling (required fields only)
# - Update operations on nested fields
# - Retrieval and validation of nested data structures
# - Error handling for invalid nested data
#
# The nested structure includes:
# - Address: street, city, state, zip_code, country
# - Profile: occupation, company, phone, preferences (newsletter, notifications, theme)
# =============================================================================

Create User With Nested Fields - Valid Data
    [Documentation]    Test creating a user with valid nested address and profile data
    [Tags]    post    users    nested    create
    ${response}=    POST    ${BASE_URL}/users    json=${VALID_USER}
    ${json_response}=    Validate User Response With Nested Fields    ${response}    201
    
    # Validate basic user data
    Should Be Equal    ${json_response['data']['name']}    Test User
    Should Be Equal    ${json_response['data']['email']}    test@example.com
    Should Be Equal As Numbers    ${json_response['data']['age']}    28
    
    # Validate address data
    Should Be Equal    ${json_response['data']['address']['street']}    123 Main Street
    Should Be Equal    ${json_response['data']['address']['city']}    New York
    Should Be Equal    ${json_response['data']['address']['state']}    NY
    Should Be Equal    ${json_response['data']['address']['zip_code']}    10001
    Should Be Equal    ${json_response['data']['address']['country']}    USA
    
    # Validate profile data
    Should Be Equal    ${json_response['data']['profile']['occupation']}    Software Developer
    Should Be Equal    ${json_response['data']['profile']['company']}    Tech Corp
    Should Be Equal    ${json_response['data']['profile']['phone']}    +1-555-123-4567
    
    # Validate preferences
    Should Be True    ${json_response['data']['profile']['preferences']['newsletter']}
    Should Not Be True    ${json_response['data']['profile']['preferences']['notifications']}
    Should Be Equal    ${json_response['data']['profile']['preferences']['theme']}    dark
    
    Set Suite Variable    ${NESTED_USER_ID}    ${json_response['data']['id']}

Create User With Minimal Nested Fields - Valid Data
    [Documentation]    Test creating a user with minimal required nested fields
    [Tags]    post    users    nested    minimal
    ${response}=    POST    ${BASE_URL}/users    json=${VALID_USER_MINIMAL_NESTED}
    ${json_response}=    Validate User Response With Nested Fields    ${response}    201
    
    # Validate basic user data
    Should Be Equal    ${json_response['data']['name']}    Minimal User
    Should Be Equal    ${json_response['data']['email']}    minimal@example.com
    Should Be Equal As Numbers    ${json_response['data']['age']}    25
    
    # Validate minimal address data
    Should Be Equal    ${json_response['data']['address']['street']}    Simple Street
    Should Be Equal    ${json_response['data']['address']['city']}    Simple City
    
    # Validate minimal profile data
    Should Be Equal    ${json_response['data']['profile']['occupation']}    Student
    
    Set Suite Variable    ${MINIMAL_NESTED_USER_ID}    ${json_response['data']['id']}

Update User With Nested Fields - Valid Data
    [Documentation]    Test updating a user with nested field changes
    [Tags]    put    users    nested    update
    &{address_dict}=    Create Dictionary    street=456 Updated St    city=Updated City    state=UC    zip_code=54321    country=Updated Country
    &{preferences_dict}=    Create Dictionary    newsletter=${False}    notifications=${True}    theme=light
    &{profile_dict}=    Create Dictionary    occupation=Senior Developer    company=Updated Corp    phone=+1-555-999-8888    preferences=${preferences_dict}
    &{updated_nested_user}=    Create Dictionary    
    ...    name=Updated Nested User    
    ...    email=updated.nested@example.com    
    ...    age=${35}
    ...    address=${address_dict}
    ...    profile=${profile_dict}
    
    ${response}=    PUT    ${BASE_URL}/users/${NESTED_USER_ID}    json=${updated_nested_user}
    ${json_response}=    Validate User Response With Nested Fields    ${response}    200
    
    # Validate updated basic data
    Should Be Equal    ${json_response['data']['name']}    Updated Nested User
    Should Be Equal    ${json_response['data']['email']}    updated.nested@example.com
    Should Be Equal As Numbers    ${json_response['data']['age']}    35
    
    # Validate updated address
    Should Be Equal    ${json_response['data']['address']['street']}    456 Updated St
    Should Be Equal    ${json_response['data']['address']['city']}    Updated City
    
    # Validate updated profile
    Should Be Equal    ${json_response['data']['profile']['occupation']}    Senior Developer
    Should Be Equal    ${json_response['data']['profile']['company']}    Updated Corp

Get User With Nested Fields - Valid ID
    [Documentation]    Test retrieving a user with nested fields by valid ID
    [Tags]    get    users    nested    id
    ${response}=    GET    ${BASE_URL}/users/${NESTED_USER_ID}
    ${json_response}=    Validate User Response With Nested Fields    ${response}    200
    
    # Validate complete nested structure exists
    Validate Full Nested User Structure    ${json_response['data']}
    Validate User Preferences    ${json_response['data']['profile']}

# =============================================================================
# Negative Test Cases for Nested Data Structures
#
# This section contains negative test scenarios that validate proper error
# handling when invalid or incomplete nested data is provided. These tests
# ensure the API correctly rejects malformed requests and provides meaningful
# error messages for debugging and user feedback.
#
# Test scenarios include:
# - Invalid data types in nested fields
# - Missing required nested fields
# - Empty values in required nested fields
# - Invalid format values (phone, email, zip codes)
# =============================================================================

Create User With Invalid Nested Data - Negative Test
    [Documentation]    Test creating a user with invalid nested field data should fail
    [Tags]    post    users    nested    negative
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_INVALID_NESTED_DATA}    expected_status=400
    Should Be Equal As Numbers    ${response.status_code}    400
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response}    error

Create User With Missing Required Nested Fields - Negative Test
    [Documentation]    Test creating a user with missing required nested fields should fail
    [Tags]    post    users    nested    negative
    ${response}=    POST    ${BASE_URL}/users    json=${USER_WITH_MISSING_NESTED_REQUIRED}    expected_status=400
    Should Be Equal As Numbers    ${response.status_code}    400
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response}    error

# =============================================================================
# Test Data Cleanup Section
#
# This section handles the cleanup of test data created during the nested field
# tests. It ensures that any test users created during the test execution are
# properly removed from the database, preventing test data pollution and 
# maintaining test independence.
#
# Cleanup operations:
# - Delete all users created with nested field data
# - Handle cleanup gracefully even if deletion fails
# - Log cleanup operations for debugging purposes
# =============================================================================

Delete Nested Field Test Users - Cleanup
    [Documentation]    Clean up test users with nested fields
    [Tags]    delete    users    nested    cleanup
    [Teardown]    Log    Nested field test users cleanup completed
    
    # Delete nested user if exists
    Run Keyword And Ignore Error    Delete User By ID    ${NESTED_USER_ID}
    
    # Delete minimal nested user if exists
    Run Keyword And Ignore Error    Delete User By ID    ${MINIMAL_NESTED_USER_ID}