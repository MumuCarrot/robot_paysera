from robot.libraries.BuiltIn import BuiltIn
from robot.utils.asserts import fail
import os
import allure


ROBOT_LIBRARY_SCOPE = 'Global'

def capture_page_screenshot(path, screen_name):
    try:
        if not path or not os.path.exists(path):
            return path

        # Try attaching via allure_robotframework library first (preferred)
        try:
            BuiltIn().run_keyword('Allure.Attach File', path, screen_name)
            return path
        except Exception as lib_err:
            try:
                BuiltIn().log(f"Allure.Attach File failed: {lib_err}", level='DEBUG')
            except Exception:
                pass

        # Fallback to Python Allure API (attach binary content)
        try:
            with open(path, 'rb') as fh:
                data = fh.read()
            allure.attach(data, name=screen_name, attachment_type=allure.attachment_type.PNG, extension='png')
            return path
        except Exception as py_err:
            try:
                BuiltIn().log(f"Allure python attach failed: {py_err}", level='WARN')
            except Exception:
                pass
    except Exception as err:
        try:
            BuiltIn().log(f"Allure attach error: {err}", level='WARN')
        except Exception:
            pass
    return path