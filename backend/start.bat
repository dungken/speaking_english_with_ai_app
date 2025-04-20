@echo off
REM Simple start script for local development on Windows

REM Activate virtual environment if it exists
if exist .venv\Scripts\activate.bat (
    call .venv\Scripts\activate.bat
)

REM Set Python path to include the current directory
set PYTHONPATH=%PYTHONPATH%;%CD%

REM Run the application
python main.py
