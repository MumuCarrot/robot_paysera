*** Settings ***
Library    OperatingSystem
Library    AppiumLibrary
Library    ../libraries/baseTests.py    WITH NAME    BaseLib

*** Keywords ***
Capture Appium Screenshot And Attach
    [Arguments]    ${name}=${TEST_NAME}
    ${dir}=    Set Variable    ${OUTPUTDIR}/appium/screenshot
    Create Directory    ${dir}
    ${path}=    Set Variable    ${dir}/${name}.png
    Run Keyword And Ignore Error    AppiumLibrary.Capture Page Screenshot    ${path}
    BaseLib.Capture Page Screenshot    ${path}    ${name}
    RETURN    ${path}

Set Appium Screenshot On Failure
    Register Keyword To Run On Failure    Capture Appium Screenshot And Attach

