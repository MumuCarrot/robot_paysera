*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    JSONLibrary

Resource    keywords/api_tests_keywords.robot

Suite Setup    Create Session    api    http://localhost:3000
Suite Teardown    Delete All Sessions

*** Test Cases ***
API Health Check
    [Documentation]    Test that API server is running and responding
    [Tags]    health    smoke
    ${response}=    GET    ${BASE_URL}/
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    API Server is running!
    Should Contain    ${json_response}    endpoints

Get All Users - Initial Data
    [Documentation]    Test getting all users from the API
    [Tags]    get    users
    ${response}=    GET    ${BASE_URL}/users
    Should Be Equal As Numbers    ${response.status_code}    200
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    Users retrieved successfully
    Should Be True    ${json_response['count']} >= 0
    Should Contain    ${json_response}    data

Create New User - Valid Data
    [Documentation]    Test creating a new user with valid data
    [Tags]    post    users    create
    ${response}=    POST    ${BASE_URL}/users    json=${VALID_USER}
    Should Be Equal As Numbers    ${response.status_code}    201
    ${json_response}=    Set Variable    ${response.json()}
    Should Contain    ${json_response['message']}    User created successfully
    Should Contain    ${json_response['data']}    id
    Should Be Equal    ${json_response['data']['name']}    Test User
    Should Be Equal    ${json_response['data']['email']}    test@example.com
    Should Be Equal As Numbers    ${json_response['data']['age']}    28
    Set Suite Variable    ${CREATED_USER_ID}    ${json_response['data']['id']}

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
    ${response}=    GET    ${BASE_URL}/users/99999    expected_status=404
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
    ${response}=    PUT    ${BASE_URL}/users/99999    json=${updated_user}    expected_status=404
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
    ${response}=    DELETE    ${BASE_URL}/users/99999    expected_status=404
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
