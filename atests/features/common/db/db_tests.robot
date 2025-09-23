*** Settings ***
Resource    keywords/db_keywords.robot
Documentation    Direct SQLite tests without API. Covers schema reset, CRUD, and constraints.
Default Tags    db    sqlite    no_api

Suite Setup       Open Test Database Connection
Suite Teardown    Close Test Database Connection

*** Test Cases ***
Scenario: Database schema reset and sample users seeded successfully
    [Documentation]    As a tester I want the database schema reset with seed data so tests start from a known state.
    [Tags]    db    smoke_test    api_independent
    Given Database Schema Is Reset
    When Sample Users Are Seeded    3
    Then Users Count Should Equal    3

Scenario: User can be created and retrieved by email
    [Documentation]    As a tester I want to create a user directly so I can retrieve and validate stored values.
    [Tags]    db    create    read
    Given Database Schema Is Reset
    When User Is Created With Details    Alice Doe    alice@example.com    27
    Then User With Email Should Have Details    alice@example.com    Alice Doe    27

Scenario: Creating user with duplicate email should fail
    [Documentation]    As a tester I expect duplicate emails to violate constraints so data integrity is preserved.
    [Tags]    db    constraint    negative
    Given Database Schema Is Reset
    And User Exists With Details    Bob Tester    bob@example.com    30
    When Creating User With Duplicate Email Should Fail    Bob Clone    bob@example.com

Scenario: User email can be updated and user removed
    [Documentation]    As a tester I want to update and remove a user so data changes persist correctly.
    [Tags]    db    update    delete
    Given Database Schema Is Reset
    And User Exists With Details    Carol User    carol@example.com    22
    When User Email Is Updated From To    carol@example.com    carol.updated@example.com
    Then User With Email Should Have Details Validation    carol.updated@example.com    Carol User
    When User With Email Is Deleted    carol.updated@example.com
    Then User With Email Should Not Exist    carol.updated@example.com


