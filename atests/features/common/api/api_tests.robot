*** Settings ***
# Import required libraries for comprehensive API testing
Library    RequestsLibrary    # HTTP request/response handling for API testing
Library    Collections         # Python collections for data structure manipulation  
Library    String              # String operations and validation utilities
Library    JSONLibrary         # JSON parsing and validation functionality

# Import API-specific keywords and test data
Resource    keywords/api_tests_keywords.robot    # API test keywords and BDD-style keywords (Given-When-Then)
Variables   elements/api_tests.yaml             # API test data and configuration

# Suite-level setup and teardown configuration
Suite Setup    Create Session    api    http://localhost:3000    # Initialize HTTP session for API communication
Suite Teardown    Delete All Sessions                            # Clean up all HTTP sessions

# =============================================================================
# BDD API Test Suite - Converted from Traditional Robot Framework Tests
# =============================================================================
# 
# This test suite has been converted to use BDD (Behavior-Driven Development) format
# following the Given-When-Then pattern. Each test case now reads like a natural
# language specification of the system behavior.
#
# BDD Pattern:
# - Given: Set up the initial context/preconditions
# - When: Execute the action being tested
# - Then: Assert the expected outcome
# - And: Additional steps to chain with Given/When/Then
#
# Benefits:
# - More readable and understandable test specifications
# - Better communication between technical and non-technical stakeholders
# - Clear separation of test setup, action, and verification
# - Follows industry standard BDD practices
# =============================================================================

*** Test Cases ***
# =============================================================================
# BDD API Tests - Health and Basic Operations
# =============================================================================

API Server Should Be Operational
    [Documentation]    As an API consumer, I want to verify that the API server is running
    ...                So that I can ensure the service is available for requests
    [Tags]    health    smoke_test    api_foundation    bdd
    Given API server is running
    When I request user health check
    Then the response status should be "200"
    And the response should contain "API Server is running!"
    And the response should contain API endpoints

Users Can Be Retrieved From The System
    [Documentation]    As an API consumer, I want to retrieve all users from the system
    ...                So that I can view the complete list of users
    [Tags]    get_request    user_retrieval    positive_test    bdd
    Given API server is running
    When I request all users
    Then the response status should be "200"
    And the response should contain "Users retrieved successfully"
    And the response should contain users list

New User Can Be Created With Valid Data
    [Documentation]    As an API consumer, I want to create a new user with valid data
    ...                So that the user can be added to the system
    [Tags]    post_request    user_creation    positive_test    crud_operation    bdd
    Given API server is running
    When I create a user with valid data
    Then the response status should be "201"
    And the response should contain "User created successfully"
    And the response should contain user data
    And the user should have name "${EXPECTED_USER_NAME}"
    And the user should have email "${EXPECTED_USER_EMAIL}"
    And the user should have age "${EXPECTED_USER_AGE}"

Existing User Can Be Retrieved By ID
    [Documentation]    As an API consumer, I want to retrieve a specific user by their ID
    ...                So that I can view their details
    [Tags]    get    users    id    bdd
    Given API server is running
    And a user exists with valid data
    When I request user by ID "${TEST_USER_ID}"
    Then the response status should be "200"
    And the response should contain "User retrieved successfully"
    And the user should have ID "${TEST_USER_ID}"

Existing User Can Be Updated With Valid Data
    [Documentation]    As an API consumer, I want to update a user's information
    ...                So that their data remains current
    [Tags]    put    users    update    bdd
    Given API server is running
    And a user exists with valid data
    When I update user with valid data
    Then the response status should be "200"
    And the response should contain "User updated successfully"
    And the user should have name "${EXPECTED_UPDATED_NAME}"
    And the user should have email "${EXPECTED_UPDATED_EMAIL}"
    And the user should have age "${EXPECTED_UPDATED_AGE}"

# =============================================================================
# BDD API Tests - Negative Test Scenarios
# =============================================================================

User Creation Should Fail When Email Is Missing
    [Documentation]    As an API consumer, I want to be prevented from creating a user without email
    ...                So that data integrity is maintained
    [Tags]    post    users    negative    bdd
    Given API server is running
    When I create a user with missing email
    Then the response status should be "400"
    And the response should contain error "Name and email are required fields"

User Creation Should Fail When Email Format Is Invalid
    [Documentation]    As an API consumer, I want to be prevented from creating a user with invalid email format
    ...                So that only valid email addresses are accepted
    [Tags]    post    users    negative    bdd
    Given API server is running
    When I create a user with invalid email format
    Then the response status should be "400"
    And the response should contain error "Invalid email format"

User Retrieval Should Fail When User Does Not Exist
    [Documentation]    As an API consumer, I want to receive an error when trying to get a non-existent user
    ...                So that I know the user doesn't exist in the system
    [Tags]    get    users    negative    bdd
    Given API server is running
    And the user does not exist
    When I request user by ID "${NON_EXISTENT_USER_ID}"
    Then the user should not be found

User Retrieval Should Fail When ID Format Is Invalid
    [Documentation]    As an API consumer, I want to receive an error when using invalid ID format
    ...                So that I know the ID format is incorrect
    [Tags]    get    users    negative    bdd
    Given API server is running
    When I request user by invalid ID format
    Then the response status should be "400"
    And the response should contain error "Invalid user ID"

User Update Should Fail When User Does Not Exist
    [Documentation]    As an API consumer, I want to receive an error when trying to update a non-existent user
    ...                So that I know the user doesn't exist in the system
    [Tags]    put    users    negative    bdd
    Given API server is running
    And the user does not exist
    When I update non-existent user
    Then the user should not be found

# =============================================================================
# BDD API Tests - User Deletion Scenarios
# =============================================================================

Existing User Can Be Deleted Successfully
    [Documentation]    As an API consumer, I want to delete a user
    ...                So that they are removed from the system
    [Tags]    delete    users    bdd
    Given API server is running
    And a user exists with valid data
    When I delete user by ID
    Then the response status should be "200"
    And the response should contain "User deleted successfully"

User Deletion Should Fail When User Does Not Exist
    [Documentation]    As an API consumer, I want to receive an error when trying to delete a non-existent user
    ...                So that I know the user doesn't exist in the system
    [Tags]    delete    users    negative    bdd
    Given API server is running
    And the user does not exist
    When I delete non-existent user
    Then the user should not be found

Deleted User Should Not Be Retrievable
    [Documentation]    As an API consumer, I want to confirm that a deleted user is no longer accessible
    ...                So that I know the deletion was successful
    [Tags]    get    users    verification    bdd
    Given API server is running
    And a user exists with valid data
    And I delete user by ID
    When I request user by ID "${DELETED_USER_ID}"
    Then the user should not be found

# =============================================================================
# BDD API Tests - Advanced Nested Data Structure Scenarios
# =============================================================================

User With Complete Nested Data Can Be Created Successfully
    [Documentation]    As an API consumer, I want to create a user with complete address and profile information
    ...                So that comprehensive user data is stored in the system
    ...                Nested data includes: Address (street, city, state, zip_code, country)
    ...                and Profile (occupation, company, phone, preferences)
    [Tags]    post    users    nested    create    bdd
    Given API server is running
    When I create a user with valid data
    Then the response status should be "201"
    And the response should contain "User created successfully"
    And the response should contain nested user data
    And the user should have name "${EXPECTED_USER_NAME}"
    And the user should have email "${EXPECTED_USER_EMAIL}"
    And the user should have age "${EXPECTED_USER_AGE}"

User With Minimal Nested Data Can Be Created Successfully
    [Documentation]    As an API consumer, I want to create a user with minimal required nested fields
    ...                So that users can be created with only essential nested information
    [Tags]    post    users    nested    minimal    bdd
    Given API server is running
    When I create a user with valid data
    Then the response status should be "201"
    And the response should contain "User created successfully"
    And the response should contain nested user data

User With Nested Fields Can Be Updated Successfully
    [Documentation]    As an API consumer, I want to update a user's nested field information
    ...                So that their address and profile data can be modified
    [Tags]    put    users    nested    update    bdd
    Given API server is running
    And a user exists with nested data
    When I update user with nested data
    Then the response status should be "200"
    And the response should contain "User updated successfully"
    And the response should contain nested user data
    And the user should have name "${EXPECTED_NESTED_UPDATED_NAME}"
    And the user should have email "${EXPECTED_NESTED_UPDATED_EMAIL}"
    And the user should have age "${EXPECTED_NESTED_UPDATED_AGE}"

User With Nested Fields Can Be Retrieved Successfully
    [Documentation]    As an API consumer, I want to retrieve a user with complete nested field data
    ...                So that I can access their full address and profile information
    [Tags]    get    users    nested    id    bdd
    Given API server is running
    And a user exists with nested data
    When I request user by ID "${NESTED_TEST_USER_ID}"
    Then the response status should be "200"
    And the response should contain "User retrieved successfully"
    And the response should contain nested user data

# =============================================================================
# BDD API Tests - Negative Nested Data Scenarios
# =============================================================================

User Creation Should Fail With Invalid Nested Data
    [Documentation]    As an API consumer, I want to be prevented from creating a user with invalid nested data
    ...                So that data integrity is maintained for complex user structures
    [Tags]    post    users    nested    negative    bdd
    Given API server is running
    When I create a user with invalid nested data
    Then the response status should be "400"
    And the response should contain error ""

User Creation Should Fail With Missing Required Nested Fields
    [Documentation]    As an API consumer, I want to be prevented from creating a user with missing required nested fields
    ...                So that essential nested information is always provided
    [Tags]    post    users    nested    negative    bdd
    Given API server is running
    When I create a user with missing required nested fields
    Then the response status should be "400"
    And the response should contain error ""

# =============================================================================
# BDD API Tests - Test Data Cleanup Scenarios
# =============================================================================

Test Data Should Be Cleaned Up After Nested Field Tests
    [Documentation]    As a test system, I want to ensure that test users with nested fields are cleaned up
    ...                So that test data doesn't pollute the database
    [Tags]    delete    users    nested    cleanup    bdd
    [Teardown]    Log    Nested field test users cleanup completed
    Given API server is running
    When I clean up nested field test users
    Then all test users should be removed from the system