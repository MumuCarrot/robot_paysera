*** Settings ***
Resource         ../../tribe_beta_variables.robot
Variables        ../elements/android_app_tests.yaml
Library          AppiumLibrary    timeout=30s
Resource         ../../../../support/resources/appium_screenshot_helpers.robot

*** Keywords ***
Start Session
    Open Application    ${APPIUM_SERVER_URL}    &{ANDROID_APP_CAPS}

End Session
    Close Application

User Navigates To Favorites Tab
    Click Element    ${FAVORITES_TAB}

User Navigates To Recents Tab
    Click Element    ${RECENTS_TAB}

User Navigates To Contacts Tab
    Click Element    ${CONTACTS_TAB}

Favorites Tab Should Be Active
    Wait Until Page Contains    Favorites    timeout=5s
    Page Should Contain Element    ${FAVORITES_TAB}    selected=true

Recents Tab Should Be Active
    Wait Until Page Contains    Recents    timeout=5s
    Page Should Contain Element    ${RECENTS_TAB}    selected=true

Contacts Tab Should Be Active
    Wait Until Page Contains    Contacts    timeout=5s
    Page Should Contain Element    ${CONTACTS_TAB}    selected=true
