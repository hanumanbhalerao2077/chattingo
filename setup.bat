@echo off
REM ============================================
REM Chattingo - Quick Setup Script (Windows)
REM ============================================
REM This script automates the Docker setup for local development on Windows
REM Usage: setup.bat

setlocal enabledelayedexpansion

REM Color codes (limited on Windows)
REM Unfortunately, Windows CMD has limited color support
REM We'll use simple text indicators instead

echo.
echo ======================================
echo   Chattingo - Docker Setup (Windows)
echo ======================================
echo.

REM Check for Docker
echo Checking prerequisites...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed
    echo Install from: https://www.docker.com/products/docker-desktop
    exit /b 1
) else (
    echo [OK] Docker installed
    docker --version
)

REM Check for Docker Compose
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed
    echo Install from: https://docs.docker.com/compose/install/
    exit /b 1
) else (
    echo [OK] Docker Compose installed
    docker-compose --version
)

REM Check for Git
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed
    echo Install from: https://git-scm.com/downloads
    exit /b 1
) else (
    echo [OK] Git installed
    git --version
)

echo.
echo ======================================
echo Setting Up Environment Files
echo ======================================
echo.

REM Create backend .env
if not exist "backend\.env" (
    copy "backend\.env.example" "backend\.env" >nul
    echo [OK] Created backend\.env
) else (
    echo [WARNING] backend\.env already exists, skipping
)

REM Create frontend .env
if not exist "frontend\.env.development.local" (
    copy "frontend\.env.example" "frontend\.env.development.local" >nul
    echo [OK] Created frontend\.env.development.local
) else (
    echo [WARNING] frontend\.env.development.local already exists, skipping
)

echo.
echo ======================================
echo Building Docker Images
echo ======================================
echo.
echo [INFO] This may take several minutes...
echo.

echo [INFO] Building backend image...
docker-compose build backend
if errorlevel 1 (
    echo [ERROR] Failed to build backend image
    exit /b 1
)
echo [OK] Backend image built
echo.

echo [INFO] Building frontend image...
docker-compose build frontend
if errorlevel 1 (
    echo [ERROR] Failed to build frontend image
    exit /b 1
)
echo [OK] Frontend image built
echo.

echo [INFO] Building MySQL image...
docker-compose build mysql >nul 2>&1 || (
    echo [WARNING] MySQL image may be pre-built
)
echo.

echo ======================================
echo Starting Services
echo ======================================
echo.

echo [INFO] Starting Docker containers...
docker-compose up -d

if errorlevel 1 (
    echo [ERROR] Failed to start services
    exit /b 1
)

echo [OK] Docker services started
echo [INFO] Waiting for services to initialize...
timeout /t 20 /nobreak

echo.
echo ======================================
echo Verifying Services
echo ======================================
echo.

echo [INFO] Container status:
docker-compose ps

echo.
echo [INFO] Testing backend connection...
curl -f http://localhost:8080/auth >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Backend may still be initializing
) else (
    echo [OK] Backend is responding
)

echo.
echo [INFO] Testing frontend connection...
curl -f http://localhost/health >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Frontend may still be initializing
) else (
    echo [OK] Frontend is responding
)

echo.
echo ======================================
echo Setup Complete!
echo ======================================
echo.
echo Application is ready to use!
echo.
echo Access URLs:
echo   Frontend:     http://localhost
echo   Backend API:  http://localhost:8080
echo   Database:     localhost:3306
echo.
echo Default Credentials:
echo   Database Root Password: root
echo   Database User: chattingo_user
echo   Database Name: chattingo_db
echo.
echo Next Steps:
echo   1. Open http://localhost in your browser
echo   2. Sign up for a new account
echo   3. Create another account and test messaging
echo.
echo Useful Commands:
echo   View logs:        docker-compose logs -f
echo   Stop services:    docker-compose stop
echo   Stop ^& remove:    docker-compose down
echo   Remove volumes:   docker-compose down -v
echo.
echo Troubleshooting:
echo   If services don't start:
echo   - Check Docker Desktop is running
echo   - View logs: docker-compose logs -f backend
echo   - Check ports: netstat -ano ^| findstr :8080
echo.

pause
