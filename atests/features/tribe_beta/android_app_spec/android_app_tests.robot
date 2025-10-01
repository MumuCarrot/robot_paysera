*** Settings ***
Resource         keywords/android_app_keywords.robot
Library          AppiumLibrary    timeout=30s
Resource         ../../../support/resources/appium_screenshot_helpers.robot
Test Setup       Start Session
Test Teardown    Run Keywords    Capture Appium Screenshot And Attach    ${TEST_NAME}    AND    End Session

*** Test Cases ***
Scenario - As User, I Can See Contacts Tab Upon Opening App
    [Tags]    android    app    phone    smoke
    Given Contacts Tab Should Be Active

Scenario - As User, I Can Navigate To Favorites Tab
    [Tags]    android    app    phone    navigation
    Given Contacts Tab Should Be Active
    When Contacts Tab Should Be Active
    Then User Navigates To Favorites Tab
    Then Favorites Tab Should Be Active

Scenario - As User, I Can Navigate To Recents Tab
    [Tags]    android    app    phone    navigation
    Given Favorites Tab Should Be Active
    When User Navigates To Recents Tab
    Then Recents Tab Should Be Active
