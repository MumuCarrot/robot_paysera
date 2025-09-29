## Appium setup and run guide (Windows)

This guide walks you through installing Android tooling and Appium, configuring your environment, and running the Robot Framework Android tests in this project.

### Prerequisites
- Windows 10/11
- Admin rights to install software
- Python 3.10+ and pip (already used by this project)

### 1) Install core toolchain
1) Install Node.js LTS
   - Download and install: [Node.js LTS](https://nodejs.org/en)
   - Verify:
```powershell
node -v
npm -v
```

2) Install a JDK (recommended: Temurin 17)
   - Download: [Temurin (Adoptium) JDK 17](https://adoptium.net/temurin/releases/?version=17)
   - After install, set `JAVA_HOME` (if not set by installer) to the JDK directory and add `%JAVA_HOME%\bin` to PATH.
   - Verify:
```powershell
java -version
```

3) Install Android Studio and SDK components
   - Download: [Android Studio](https://developer.android.com/studio)
   - During first run, in SDK Manager:
     - SDK Platforms: install at least Android 13/14
     - SDK Tools: check and install
       - Android SDK Platform-Tools
       - Android SDK Command-line Tools (latest)
       - Android Emulator

4) Set Android environment variables (User-level)
   - Default SDK path on Windows: `C:\Users\<YOUR_USER>\AppData\Local\Android\Sdk`
```powershell
# Replace <YOUR_USER> accordingly
setx ANDROID_HOME "C:\Users\<YOUR_USER>\AppData\Local\Android\Sdk"
setx ANDROID_SDK_ROOT "%ANDROID_HOME%"

# Add to PATH (Platform-Tools, Emulator, Tools)
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\emulator;%ANDROID_HOME%\cmdline-tools\latest\bin"
```
   - Open a new terminal and verify:
```powershell
adb --version
sdkmanager --list | Select-String -Pattern "Installed packages"
```

### 2) Create and start an Android emulator
- Option A (Recommended): Android Studio → Device Manager → Create Virtual Device → Choose Pixel device → System image with Google APIs → Finish → Start.
- Option B (CLI):
```powershell
# Example for API 34, Google APIs, x86_64
sdkmanager "platform-tools" "platforms;android-34" "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n Pixel_7_API_34 -k "system-images;android-34;google_apis;x86_64" --device "pixel_7" --force
emulator -avd Pixel_7_API_34
```
Verify the emulator is visible:
```powershell
adb devices
```

### 3) Install Appium and helpers (Node global)
1) Install Appium v3 and the Android driver (UiAutomator2):
```powershell
npm i -g appium@latest
appium -v
appium driver install uiautomator2
```

2) Make sure your global npm bin directory is on PATH
- On Windows (user install), global executables are usually in `%APPDATA%\npm`.
- Ensure `%APPDATA%\npm` is in your PATH so `appium` is recognized in any terminal.

3) Install Appium Doctor (optional but recommended):
```powershell
npm i -g @appium/doctor
appium-doctor --android
```

### 4) Project Python dependencies
Install all required Python libraries for this project (includes `Appium-Python-Client` and `robotframework-appiumlibrary`):
```powershell
pip install -r requirements.txt
```

### 5) Mobile Chrome setup and Chromedriver options
- For mobile web tests, your emulator should have Chrome. With Play Store images, Chrome is preinstalled. If not, update/install Chrome via Play Store or sideload an APK.
- Check the Chrome version on the emulator (open Chrome and visit `chrome://version`).

You have two options to match Chromedriver:

Option A (Preferred): Let Appium auto-download a compatible Chromedriver. Appium v3 requires an insecure feature flag that is scoped to the driver name.
```powershell
appium --base-path /wd/hub --allow-insecure "uiautomator2:chromedriver_autodownload" -p 4723
```

Option B (Fallback): Use an explicit Chromedriver binary and point a capability to it.
```powershell
# Install a matching driver, e.g., for Chrome 134
npm i -g chromedriver@134

# Find the path (typical):
echo %APPDATA%\npm\node_modules\chromedriver\lib\chromedriver\chromedriver.exe

# In Robot test capabilities, set
# chromedriverExecutable=<that absolute path>
```

This project’s Android test is already configured to use `/wd/hub` and can either rely on auto-download (Option A) or on a pinned `chromedriverExecutable` path (Option B).

### 6) Running the test suite
1) Start the emulator (ensure it shows in `adb devices`).
2) Start Appium server (choose one of the Chromedriver options):
```powershell
# Option A: auto-download Chromedriver
appium --base-path /wd/hub --allow-insecure "uiautomator2:chromedriver_autodownload" -p 4723

# Option B: explicit Chromedriver (no insecure flag required)
appium --base-path /wd/hub -p 4723
```
3) In another terminal, from the project root, run the Android-tagged tests:
```powershell
python -m robot --listener "allure_robotframework:./allure-results" -i android -d my_reports ./
```

If the site at `${URL_SITE}` opens in Chrome on the emulator and the page contains “Swag Labs”, the test passes.

### 7) Troubleshooting
- Appium command not found
  - Ensure `%APPDATA%\npm` is in PATH.
- Emulator not detected by ADB
  - `adb kill-server && adb start-server && adb devices`
  - Ensure the emulator is actually running and unlocked.
- Error: Activity class does not exist
  - That typically applies when launching native apps via `appPackage`/`appActivity`. For mobile web, use `browserName=Chrome` in capabilities as in this project.
- Chromedriver mismatch errors
  - Prefer Option A (auto-download) with the exact flag: `--allow-insecure "uiautomator2:chromedriver_autodownload"`.
  - Or install/pin an explicit Chromedriver (Option B) and set `chromedriverExecutable` to its absolute path.
- Permissions/SDK tools not found
  - Confirm `ANDROID_HOME`, `ANDROID_SDK_ROOT`, and PATH entries to `platform-tools`, `emulator`, and `cmdline-tools` are correct.

### 8) Useful commands
```powershell
# Show Chrome package info (version, etc.)
adb shell dumpsys package com.android.chrome | Select-String version

# List installed packages (filter by chrome)
adb shell pm list packages | Select-String chrome

# Appium Doctor checks
appium-doctor --android
```

### 9) Notes
- Appium v3 requires installing platform drivers explicitly (we use `uiautomator2`).
- This repository uses Robot Framework; Python dependencies are managed in `requirements.txt`.
- The tests assume the Appium server is reachable at `http://localhost:4723/wd/hub`.


