#!/usr/bin/env bash
set -euo pipefail

# Activate Python virtual environment (Linux/macOS)
if [[ -f ".venv/bin/activate" ]]; then
  # shellcheck disable=SC1091
  source ".venv/bin/activate"
else
  echo "Virtual environment not found at .venv" >&2
  exit 1
fi

# Start Appium server
appium --base-path /wd/hub --allow-insecure "uiautomator2:chromedriver_autodownload" -p 4723


