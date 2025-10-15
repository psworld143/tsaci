@echo off
REM TSACI Database Import Script for Windows
REM This script will create and populate the tsaci_db database

echo =========================================
echo TSACI Database Import Script
echo =========================================
echo.

REM Set MySQL path (adjust if needed)
set MYSQL_PATH=C:\xampp\mysql\bin\mysql.exe
set MYSQLDUMP_PATH=C:\xampp\mysql\bin\mysqldump.exe

REM Check if MySQL is accessible
echo Checking MySQL connection...
%MYSQL_PATH% -u root -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [FAILED]
    echo Error: Cannot connect to MySQL.
    echo Please ensure MySQL is running and accessible with root user.
    pause
    exit /b 1
)
echo [OK]

REM Backup existing database if it exists
echo Checking for existing database...
%MYSQL_PATH% -u root -e "USE tsaci_db;" >nul 2>&1
if not errorlevel 1 (
    echo [EXISTS]
    echo Creating backup...
    %MYSQLDUMP_PATH% -u root tsaci_db > tsaci_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql 2>nul
    echo [OK]
) else (
    echo [NOT FOUND]
)

REM Drop and recreate database
echo Creating fresh database...
%MYSQL_PATH% -u root -e "DROP DATABASE IF EXISTS tsaci_db; CREATE DATABASE tsaci_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if errorlevel 1 (
    echo [FAILED]
    pause
    exit /b 1
)
echo [OK]

REM Import complete dump
echo Importing database structure and data...
%MYSQL_PATH% -u root tsaci_db < tsaci_complete_dump.sql 2>nul
if errorlevel 1 (
    echo [FAILED]
    pause
    exit /b 1
)
echo [OK]

REM Verify import
echo.
echo Verifying import...
echo ====================
%MYSQL_PATH% -u root tsaci_db -e "SELECT 'users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'products', COUNT(*) FROM products UNION ALL SELECT 'inventory', COUNT(*) FROM inventory UNION ALL SELECT 'production_batches', COUNT(*) FROM production_batches UNION ALL SELECT 'batch_workers', COUNT(*) FROM batch_workers UNION ALL SELECT 'material_withdrawals', COUNT(*) FROM material_withdrawals UNION ALL SELECT 'customers', COUNT(*) FROM customers UNION ALL SELECT 'sales', COUNT(*) FROM sales UNION ALL SELECT 'expenses', COUNT(*) FROM expenses UNION ALL SELECT 'production', COUNT(*) FROM production;"

echo.
echo =========================================
echo Database import completed successfully!
echo =========================================
echo.
echo You can now start the application.
echo.
echo Default login credentials:
echo   Admin: admin@tsaci.com / admin123
echo   Production Manager: manager@tsaci.com / manager123
echo.
pause

