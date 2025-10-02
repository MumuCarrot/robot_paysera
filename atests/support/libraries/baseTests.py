from robot.libraries.BuiltIn import BuiltIn
from robot.utils.asserts import fail
import os
import allure
import shutil
import uuid
import json
import glob
import subprocess
import time
import platform
import sys

ROBOT_LIBRARY_SCOPE = 'Global'
SLEEP_TIME_APPIUM_SERVER = 10

def _find_appium_command():
    """Find the correct Appium command for the current platform."""
    if platform.system() == 'Windows':
        # On Windows, try to find appium.cmd first, then appium
        # shutil.which() will search in PATH
        appium_cmd = shutil.which('appium.cmd') or shutil.which('appium')
        if appium_cmd:
            BuiltIn().log(f"Found Appium at: {appium_cmd}", level='DEBUG')
            return appium_cmd
        # Fallback: try common npm global install location
        npm_appium = os.path.join(os.environ.get('APPDATA', ''), 'npm', 'appium.cmd')
        if os.path.exists(npm_appium):
            BuiltIn().log(f"Found Appium at: {npm_appium}", level='DEBUG')
            return npm_appium
        return 'appium.cmd'  # Last resort
    else:
        # On Unix/Linux/Mac, just use 'appium'
        appium_cmd = shutil.which('appium')
        if appium_cmd:
            BuiltIn().log(f"Found Appium at: {appium_cmd}", level='DEBUG')
            return appium_cmd
        return 'appium'

def start_appium():
    """Start Appium server if it's not already running."""
    if is_appium_running():
        BuiltIn().log("Appium is already running", level='INFO')
        return
    
    BuiltIn().log("Starting Appium server...", level='INFO')
    
    try:
        # Find the correct Appium command for this platform
        appium_cmd = _find_appium_command()
        BuiltIn().log(f"Using Appium command: {appium_cmd}", level='INFO')
        
        # Start Appium in background using Popen (non-blocking)
        # appium --base-path /wd/hub --allow-insecure "uiautomator2:chromedriver_autodownload" -p 4723
        if platform.system() == 'Windows':
            # On Windows, use CREATE_NO_WINDOW flag to hide console and shell=True for .cmd files
            subprocess.Popen(
                [appium_cmd, '--base-path', '/wd/hub', '--allow-insecure', 'uiautomator2:chromedriver_autodownload', '-p', '4723'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                shell=True,  # Required for .cmd files on Windows
                creationflags=subprocess.CREATE_NO_WINDOW if hasattr(subprocess, 'CREATE_NO_WINDOW') else 0
            )
        else:
            # On Unix/Linux/Mac
            subprocess.Popen(
                [appium_cmd, '--base-path', '/wd/hub', '--allow-insecure', 'uiautomator2:chromedriver_autodownload', '-p', '4723'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        
        # Wait for Appium to start
        BuiltIn().log(f"Waiting {SLEEP_TIME_APPIUM_SERVER} seconds for Appium to start...", level='INFO')
        time.sleep(SLEEP_TIME_APPIUM_SERVER)
        
        # Verify it's running
        if is_appium_running():
            BuiltIn().log("Appium server started successfully", level='INFO')
        else:
            BuiltIn().log("Appium may not have started properly", level='WARN')
            
    except FileNotFoundError as e:
        BuiltIn().log(f"ERROR: 'appium' command not found. Please ensure Appium is installed and in your PATH. Error: {e}", level='ERROR')
        BuiltIn().log(f"Searched for: {appium_cmd if 'appium_cmd' in locals() else 'appium'}", level='ERROR')
        raise
    except Exception as e:
        BuiltIn().log(f"Failed to start Appium: {e}", level='ERROR')
        raise

def is_appium_running():
    """Check if Appium server is running on port 4723 (cross-platform)."""
    try:
        # Method 1: Try to connect to Appium port 4723
        import socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        result = sock.connect_ex(('localhost', 4723))
        sock.close()
        
        if result == 0:
            # Port 4723 is open, likely Appium is running
            BuiltIn().log("Detected service on port 4723 (likely Appium)", level='DEBUG')
            return True
        
        # Method 2: Check for Appium process specifically (fallback)
        if platform.system() == 'Windows':
            # On Windows, check if node.exe with "appium" in command line is running
            # Using WMIC to get process command line
            result = subprocess.run(
                ['wmic', 'process', 'where', 'name="node.exe"', 'get', 'commandline'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=5
            )
            # Check if any node.exe process has "appium" in its command line
            if result.returncode == 0 and 'appium' in result.stdout.lower():
                BuiltIn().log("Found Appium process via WMIC", level='DEBUG')
                return True
        else:
            # On Unix/Linux/Mac, use ps to find appium process
            result = subprocess.run(
                ['ps', 'aux'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                timeout=5
            )
            if 'appium' in result.stdout.lower():
                BuiltIn().log("Found Appium process via ps", level='DEBUG')
                return True
        
        return False
        
    except ImportError:
        # If socket module is not available (unlikely), fall back to basic check
        BuiltIn().log("Socket module not available, using basic process check", level='WARN')
        try:
            if platform.system() == 'Windows':
                result = subprocess.run(['tasklist', '/FI', 'IMAGENAME eq node.exe'],
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=5)
                return 'node.exe' in result.stdout.lower()
            else:
                result = subprocess.run(['ps', 'aux'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                                      text=True, timeout=5)
                return 'appium' in result.stdout.lower()
        except Exception:
            return False
    except (subprocess.TimeoutExpired, FileNotFoundError, Exception) as e:
        BuiltIn().log(f"Failed to check if Appium is running: {e}", level='WARN')
        return False

def capture_page_screenshot(path, screen_name):
    """
    Attach a screenshot to Allure report by copying it to allure-results directory.
    
    Args:
        path: Full path to the screenshot file  
        screen_name: Name to display in Allure report
        
    Returns:
        The path parameter (unchanged)
    """
    try:
        # Check if the screenshot file actually exists
        if not path:
            BuiltIn().log("Screenshot path is empty - screenshot not captured", level='WARN')
            return path
            
        if not os.path.exists(path):
            BuiltIn().log(f"Screenshot file does not exist at: {path}", level='WARN')
            BuiltIn().log("This may happen if AppiumLibrary.Capture Page Screenshot failed silently", level='WARN')
            return path
        
        # Check if file has content
        file_size = os.path.getsize(path)
        if file_size == 0:
            BuiltIn().log(f"Screenshot file is empty (0 bytes): {path}", level='WARN')
            return path
            
        BuiltIn().log(f"Attaching screenshot to Allure: {screen_name} ({file_size} bytes)", level='DEBUG')

        # Read screenshot data
        with open(path, 'rb') as fh:
            data = fh.read()
        
        # Try to attach using Python Allure API
        try:
            allure.attach(data, name=screen_name, attachment_type=allure.attachment_type.PNG)
            BuiltIn().log(f"Successfully attached screenshot to Allure via Python API: {screen_name}", level='INFO')
            return path
            
        except (KeyError, AttributeError):
            # Allure Python API context not available - manually add to allure-results
            BuiltIn().log("Allure Python API unavailable, manually adding attachment to Allure JSON", level='DEBUG')
            
            # Find allure-results directory
            exec_dir = BuiltIn().get_variable_value('${EXECDIR}')
            allure_results_dir = os.path.join(exec_dir, 'allure-results')
            
            if not os.path.exists(allure_results_dir):
                BuiltIn().log(f"allure-results directory not found at {allure_results_dir}", level='WARN')
                return path
            
            # Generate unique filename and copy screenshot
            attachment_filename = f"{uuid.uuid4().hex}-attachment.png"
            attachment_path = os.path.join(allure_results_dir, attachment_filename)
            
            shutil.copy2(path, attachment_path)
            BuiltIn().log(f"Screenshot copied to allure-results: {attachment_filename}", level='DEBUG')
            
            # Find the test result JSON file that matches the current test
            test_results = glob.glob(os.path.join(allure_results_dir, '*-result.json'))
            if test_results:
                # Get the current test name from Robot Framework context
                current_test_name = BuiltIn().get_variable_value('${TEST_NAME}', default=None)
                
                matching_result = None
                
                # Search for JSON file matching current test name
                if current_test_name:
                    for result_file in test_results:
                        try:
                            with open(result_file, 'r', encoding='utf-8') as f:
                                result_data = json.load(f)
                            
                            # Check if this JSON matches the current test name
                            if result_data.get('name') == current_test_name or result_data.get('fullName', '').endswith(current_test_name):
                                matching_result = result_file
                                break
                        except Exception:
                            continue
                
                # Fallback: use most recently modified file (within last 5 seconds)
                if not matching_result:
                    import time
                    current_time = time.time()
                    recent_results = [f for f in test_results if (current_time - os.path.getmtime(f)) < 5]
                    if recent_results:
                        matching_result = max(recent_results, key=os.path.getmtime)
                    
                if matching_result:
                    try:
                        # Read the JSON file
                        with open(matching_result, 'r', encoding='utf-8') as f:
                            result_data = json.load(f)
                        
                        # Add attachment to the attachments list
                        if 'attachments' not in result_data:
                            result_data['attachments'] = []
                        
                        result_data['attachments'].append({
                            'name': screen_name,
                            'source': attachment_filename,
                            'type': 'image/png'
                        })
                        
                        # Write back the updated JSON
                        with open(matching_result, 'w', encoding='utf-8') as f:
                            json.dump(result_data, f, indent=2)
                        
                        BuiltIn().log(f"Screenshot attached to Allure JSON for test: {current_test_name}", level='INFO')
                        
                    except Exception as json_err:
                        BuiltIn().log(f"Failed to update Allure JSON: {json_err}", level='WARN')
                else:
                    BuiltIn().log(f"Could not find matching Allure JSON for test: {current_test_name}", level='WARN')
            else:
                BuiltIn().log("No Allure test result JSON files found", level='WARN')
            
        except Exception as py_err:
            BuiltIn().log(f"Allure attachment failed: {type(py_err).__name__}: {py_err}", level='WARN')
            
    except Exception as err:
        BuiltIn().log(f"Screenshot attachment error: {err}", level='WARN')
        
    return path