@echo off
REM start_backend.bat - Script to start the AutoVRS Backend on Windows

echo 🚀 Starting AutoVRS Backend...

REM Activate virtual environment
call ..\APPAutoVRS\autovrs-env\Scripts\activate.bat

REM Set Python path
set PYTHONPATH=%CD%

REM Start the server
echo 📡 Backend will be available at: http://localhost:8000
echo 📚 API Documentation: http://localhost:8000/docs
echo 🏠 System Status API: http://localhost:8000/api/system/status
echo.

python app/main.py
