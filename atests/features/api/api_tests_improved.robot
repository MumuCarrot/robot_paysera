*** Settings ***
Library    RequestsLibrary
Library    Collections

Resource    keywords/api_tests_keywords.robot

Suite Setup    Create Session    api    http://localhost:3000
Suite Teardown    Delete All Sessions

*** Test Cases ***
API Health Check - Improved
    [Documentation]    Test API health using reusable keyword
    [Tags]    health    smoke    improved
    Verify API Is Running

User CRUD Operations - Complete Flow
    [Documentation]    Test complete user lifecycle using high-level keywords
    [Tags]    crud    users    improved
    
    # Create user
    ${user_id}=    Create Valid Test User
    Log    Created user with ID: ${user_id}
    
    # Read user  
    ${get_response}=    Get User By ID    ${user_id}
    ${user_data}=    Validate User Response Structure    ${get_response}
    Should Be Equal    ${user_data['data']['name']}    Test User
    
    # Update user
    &{updated_data}=    Create Dictionary    name=Updated User    email=updated@test.com    age=${35}
    ${update_response}=    Update User By ID    ${user_id}    ${updated_data}
    ${updated_user}=    Validate User Response Structure    ${update_response}
    Should Be Equal    ${updated_user['data']['name']}    Updated User
    
    # Delete user
    ${delete_response}=    Delete User By ID    ${user_id}
    Should Contain    ${delete_response.json()['message']}    User deleted successfully
    
    # Verify deletion
    ${verify_response}=    Get User By ID    ${user_id}    expected_status=404
    Validate Error Response    ${verify_response}    404    User not found

User Validation Tests - Improved
    [Documentation]    Test user validation using reusable keywords  
    [Tags]    validation    negative    improved
    
    # Test missing email
    ${missing_email_response}=    POST    ${BASE_URL}/users    json=${INVALID_USER_NO_EMAIL}    expected_status=400
    Validate Error Response    ${missing_email_response}    400    Name and email are required fields
    
    # Test invalid email format
    ${invalid_email_response}=    POST    ${BASE_URL}/users    json=${INVALID_EMAIL}    expected_status=400
    Validate Error Response    ${invalid_email_response}    400    Invalid email format
    
    # Test non-existent user retrieval
    ${not_found_response}=    Get User By ID    99999    expected_status=404
    Validate Error Response    ${not_found_response}    404    User not found

Bulk User Operations
    [Documentation]    Test operations with multiple users
    [Tags]    bulk    users    improved
    
    # Create multiple users
    @{user_ids}=    Create List
    FOR    ${i}    IN RANGE    3
        &{test_user}=    Create Dictionary    name=Bulk User ${i}    email=bulk${i}@test.com    age=${20 + ${i}}
        ${user_id}=    Create Test User And Return ID    ${test_user}
        Append To List    ${user_ids}    ${user_id}
    END
    
    Log    Created ${user_ids.__len__()} users: ${user_ids}
    
    # Verify all users exist
    FOR    ${user_id}    IN    @{user_ids}
        ${response}=    Get User By ID    ${user_id}
        ${user_data}=    Validate User Response Structure    ${response}
        Should Contain    ${user_data['data']['name']}    Bulk User
    END
    
    # Clean up - delete all test users
    FOR    ${user_id}    IN    @{user_ids}
        Delete Test User If Exists    ${user_id}
    END
    
    Log    Cleaned up all test users

Error Handling Edge Cases
    [Documentation]    Test various error scenarios
    [Tags]    errors    edge-cases    improved
    
    # Test invalid user ID format
    ${invalid_id_response}=    GET    ${BASE_URL}/users/invalid-id    expected_status=400
    Validate Error Response    ${invalid_id_response}    400    Invalid user ID
    
    # Test update non-existent user
    &{update_data}=    Create Dictionary    name=Ghost User    email=ghost@test.com    age=${99}
    ${update_ghost_response}=    Update User By ID    99999    ${update_data}    expected_status=404
    Validate Error Response    ${update_ghost_response}    404    User not found
    
    # Test delete non-existent user
    ${delete_ghost_response}=    Delete User By ID    99999    expected_status=404
    Validate Error Response    ${delete_ghost_response}    404    User not found
