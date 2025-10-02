*** Settings ***
Library    OperatingSystem
Library    AppiumLibrary
Library    ../libraries/baseTests.py    WITH NAME    BaseLib

*** Keywords ***
Capture Appium Screenshot And Attach
    [Documentation]    Captures screenshot using AppiumLibrary and attaches it to Allure report.
    ...                Works with both mobile web (browser) and native app contexts.
    ...                Logs detailed diagnostics if screenshot capture fails.
    [Arguments]    ${name}=${TEST_NAME}
    
    # Prepare screenshot directory and path
    ${dir}=    Set Variable    ${OUTPUTDIR}/appium/screenshot
    Create Directory    ${dir}
    ${path}=    Set Variable    ${dir}/${name}.png
    
    # Try to capture screenshot - ignore errors for graceful handling
    ${status}    ${error}=    Run Keyword And Ignore Error    AppiumLibrary.Capture Page Screenshot    ${path}
    
    # Log diagnostic information about screenshot capture result
    Run Keyword If    '${status}' == 'FAIL'    Log    AppiumLibrary.Capture Page Screenshot failed: ${error}    level=WARN
    Run Keyword If    '${status}' == 'PASS'    Log    Screenshot captured successfully to: ${path}    level=DEBUG
    
    # Check if file was actually created (even if keyword reported success)
    ${file_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${path}
    Run Keyword If    not ${file_exists}    Log    Screenshot file was not created at: ${path}    level=WARN
    
    # Attach screenshot to Allure report (will log additional warnings if file doesn't exist)
    BaseLib.Capture Page Screenshot    ${path}    ${name}
    
    RETURN    ${path}

Set Appium Screenshot On Failure
    Register Keyword To Run On Failure    Capture Appium Screenshot And Attach

