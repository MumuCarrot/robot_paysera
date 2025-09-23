*** Settings ***
Documentation    Reusable DB keywords for direct SQLite testing (no API). Provides
...    connection management, schema setup, and CRUD helpers for the `users` table.
Library    DatabaseLibrary
Library    Collections
Variables    ../elements/db_tests.yaml

*** Variables ***
${DB_PATH}          ${EXECDIR}/demo_resourses/database.sqlite

*** Keywords ***
Open Test Database Connection
    [Documentation]    Open connection to SQLite test database and set alias.
    Connect To Database    sqlite3    ${DB_PATH}    alias=${DB_ALIAS}

Close Test Database Connection
    [Documentation]    Close the active database connection.
    Disconnect From Database

Reset Users Table
    [Documentation]    Recreate users table to known schema and seed minimal data if empty.
    Execute Sql String    DROP TABLE IF EXISTS users
    Execute Sql String    CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL, age INTEGER, address TEXT, profile TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)

Insert Sample Users
    [Arguments]    ${count}=3
    FOR    ${index}    IN RANGE    ${count}
        ${name}=    Set Variable    User ${index}
        ${email}=   Set Variable    user${index}@example.com
        ${age}=     Evaluate    20 + ${index}
        Execute Sql String    INSERT INTO users (name, email, age, address, profile) VALUES ('${name}', '${email}', ${age}, NULL, NULL)
    END

Get Users Count Should Be
    [Arguments]    ${expected}
    ${rows}=    Query    SELECT COUNT(*) as cnt FROM users
    Should Be Equal As Integers    ${rows[0][0]}    ${expected}

Create User Directly
    [Arguments]    ${name}    ${email}    ${age}=
    ${age_value}=    Set Variable If    '${age}'==''    NULL    ${age}
    Execute Sql String    INSERT INTO users (name, email, age) VALUES ('${name}', '${email}', ${age_value})

Get User By Email
    [Arguments]    ${email}
    ${rows}=    Query    SELECT id, name, email, age FROM users WHERE email='${email}'
    RETURN    ${rows}

Update User Email By Id
    [Arguments]    ${id}    ${new_email}
    Execute Sql String    UPDATE users SET email='${new_email}' WHERE id=${id}

Delete User By Id
    [Arguments]    ${id}
    Execute Sql String    DELETE FROM users WHERE id=${id}

Expect Unique Email Constraint Violation
    [Arguments]    ${name}    ${email}
    Run Keyword And Expect Error    *UNIQUE*    Execute Sql String    INSERT INTO users (name, email) VALUES ('${name}', '${email}')

Given Database Schema Is Reset
    Reset Users Table

When Sample Users Are Seeded
    [Arguments]    ${count}=3
    Insert Sample Users    ${count}

And Sample Users Are Seeded
    [Arguments]    ${count}=3
    When Sample Users Are Seeded    ${count}

Then Users Count Should Equal
    [Arguments]    ${expected}
    Get Users Count Should Be    ${expected}

When User Is Created With Details
    [Arguments]    ${name}    ${email}    ${age}=
    Create User Directly    ${name}    ${email}    ${age}

Given User Exists With Details
    [Arguments]    ${name}    ${email}    ${age}=
    When User Is Created With Details    ${name}    ${email}    ${age}

And User Exists With Details
    [Arguments]    ${name}    ${email}    ${age}=
    When User Is Created With Details    ${name}    ${email}    ${age}

Then User With Email Should Have Details
    [Arguments]    ${email}    ${expected_name}    ${expected_age}=
    ${rows}=    Get User By Email    ${email}
    Length Should Be    ${rows}    1
    Should Be Equal    ${rows[0][1]}    ${expected_name}
    Should Be Equal    ${rows[0][2]}    ${email}
    Run Keyword If    '${expected_age}'!=''    Should Be Equal As Integers    ${rows[0][3]}    ${expected_age}

And User With Email Should Have Details
    [Arguments]    ${email}    ${expected_name}    ${expected_age}=
    Then User With Email Should Have Details    ${email}    ${expected_name}    ${expected_age}

When Creating User With Duplicate Email Should Fail
    [Arguments]    ${name}    ${email}
    Expect Unique Email Constraint Violation    ${name}    ${email}

When User Email Is Updated From To
    [Arguments]    ${current_email}    ${new_email}
    ${rows}=    Get User By Email    ${current_email}
    Length Should Be    ${rows}    1
    ${id}=    Set Variable    ${rows[0][0]}
    Update User Email By Id    ${id}    ${new_email}

When User With Email Is Deleted
    [Arguments]    ${email}
    ${rows}=    Get User By Email    ${email}
    Length Should Be    ${rows}    1
    Delete User By Id    ${rows[0][0]}

Then User With Email Should Not Exist
    [Arguments]    ${email}
    ${rows}=    Get User By Email    ${email}
    Length Should Be    ${rows}    0


