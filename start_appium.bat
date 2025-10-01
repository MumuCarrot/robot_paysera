@echo off
setlocal

REM Activate Python virtual environment
if exist ".venv\Scripts\activate.bat" (
    call ".venv\Scripts\activate.bat"
) else if exist ".venv\Scripts\activate" (
    call ".venv\Scripts\activate"
) else (
    echo Virtual environment not found at .venv
    exit /b 1
)

REM Start Appium server
appium --base-path /wd/hub --allow-insecure "uiautomator2:chromedriver_autodownload" -p 4723

endlocal


