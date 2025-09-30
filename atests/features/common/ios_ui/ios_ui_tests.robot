*** Settings ***
# iOS mobile web smoke test: opens Safari and verifies the target site loads.
# Uses XCUITest and Safari on an iOS emulator/device.
Library    AppiumLibrary
Resource   ../common_variables.robot
Variables  ../ui_auth/elements/ui_auth.yaml
Variables  ../../../support/resources/data/mass_of_tests.yaml
Test Teardown    Close All Applications

*** Test Cases ***
iOS Mobile Web - Open SauceDemo Home
    [Documentation]    Launches Safari on iOS and navigates to ${URL_SITE} (SauceDemo login page).
    ...                Pass criterion: initial page contains visible text 'Swag Labs'.
    ...                Purpose: sanity-check iOS mobile web setup and connectivity to Appium server.
    [Tags]    ios    smoke    mobile_web
    # Start Safari in mobile web mode.
    Given Open Application    ${APPIUM_SERVER_URL}    &{IOS_CAPS}
    # Navigate to the target site and assert a visible marker on the page.
    When Go To Url    ${URL_SITE}
    Then Wait Until Page Contains    Swag Labs    15s

iOS Login - Successful authentication
    [Documentation]    Validates that a user can authenticate successfully on iOS Safari using
    ...                valid credentials (${USER}/${PASSWORD}). Verifies landing on the inventory page.
    [Tags]    ios    ui_auth    positive_test
    # Open Safari and navigate to the login page
    Given Open Application    ${APPIUM_SERVER_URL}    &{IOS_CAPS}
    And Go To Url    ${URL_SITE}
    # Fill the login form and submit
    When Input Text    ${USER_INPUT}    ${USER}
    And Input Text    ${PASSWORD_INPUT}    ${PASSWORD}
    And Click Element    ${LOGIN_BUTTON}
    # Validate successful login by checking Products header and inventory container
    Then Wait Until Page Contains    Products    20s
    And Wait Until Page Contains Element    ${INVENTORY_LOCATOR}    20s

iOS Login - Wrong password is rejected
    [Documentation]    Ensures invalid authentication is rejected on iOS Safari. Uses a valid
    ...                username (${USER}) with an incorrect password (${INCORRECT_PASSWORD}).
    [Tags]    ios    ui_auth    negative_test
    # Open Safari and navigate to the login page
    Given Open Application    ${APPIUM_SERVER_URL}    &{IOS_CAPS}
    And Go To Url    ${URL_SITE}
    # Attempt login with wrong password and validate error UI
    When Input Text    ${USER_input}    ${USER}
    And Input Text    ${PASSWORD_INPUT}    ${INCORRECT_PASSWORD}
    And Click Element    ${LOGIN_BUTTON}
    Then Wait Until Page Contains Element    css=h3[data-test='error']    15s
    And Wait Until Page Contains    ${ERROR_TEXT}    15s
    # Ensure login button remains visible for retry
    And Wait Until Page Contains Element    ${LOGIN_BUTTON}    10s

iOS Unauthorized Access - Inventory requires login
    [Documentation]    Attempts to access ${INVENTORY_URL} directly without prior login on iOS Safari.
    ...                Expects to be redirected to login with an access error message.
    [Tags]    ios    ui_auth    security_test
    Given Open Application    ${APPIUM_SERVER_URL}    &{IOS_CAPS}
    When Go To Url    ${INVENTORY_URL}
    # Expect an access error on the login page. Some banners may be collapsed on small screens; assert text only.
    Then Wait Until Page Contains    ${ACCCESS_ERROR_INVENTORY}    20s
