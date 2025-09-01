@echo off
setlocal enabledelayedexpansion

:: ====================================
:: GMG - Good Morning Git Utility
:: ====================================
:: A command-line utility for updating git repositories
:: Usage:
::   gmg -repo <repository-name>     : Update specific repository
::   gmg -folder <parent-folder>     : Update all repos in parent folder
::   gmg -help                       : Show this help
:: ====================================

set VERSION=1.0.0
set ERROR_COUNT=0
set PROCESSED_COUNT=0

:: Parse command line arguments
if "%1"=="" goto :show_help
if "%1"=="-help" goto :show_help
if "%1"=="--help" goto :show_help
if "%1"=="/?" goto :show_help

if "%1"=="-repo" (
    if "%2"=="" (
        echo ERROR: Repository name is required
        echo Usage: gmg -repo ^<repository-name^>
        exit /b 1
    )
    set MODE=SINGLE_REPO
    set TARGET_REPO=%2
    goto :main
)

if "%1"=="-folder" (
    if "%2"=="" (
        echo ERROR: Parent folder path is required
        echo Usage: gmg -folder ^<parent-folder-path^>
        exit /b 1
    )
    set MODE=FOLDER
    set TARGET_FOLDER=%2
    goto :main
)

echo ERROR: Invalid command. Use 'gmg -help' for usage information.
exit /b 1

:show_help
echo.
echo ====================================
echo GMG - Good Morning Git v%VERSION%
echo ====================================
echo.
echo A utility to start your day with updated repositories
echo.
echo USAGE:
echo   gmg -repo ^<repository-name^>      Update specific repository
echo   gmg -folder ^<parent-folder^>      Update all repos in parent folder
echo   gmg -help                         Show this help
echo.
echo EXAMPLES:
echo   gmg -repo next-steps-idaho-2      Update single repository
echo   gmg -folder "D:\Projects"         Update all repos in folder
echo   gmg -folder .                     Update all repos in current folder
echo.
echo FEATURES:
echo   ✓ Automatic stashing of local changes
echo   ✓ Pull with rebase for clean history
echo   ✓ Automatic reapplication of stashed changes
echo   ✓ Comprehensive error handling and reporting
echo   ✓ Support for single repo or bulk folder operations
echo.
exit /b 0

:main
echo ====================================
echo GMG - Good Morning Git v%VERSION%
echo ====================================
echo Starting time: %date% %time%
echo Mode: %MODE%

if "%MODE%"=="SINGLE_REPO" (
    echo Target repository: %TARGET_REPO%
) else (
    echo Target folder: %TARGET_FOLDER%
)

echo.

if "%MODE%"=="SINGLE_REPO" (
    call :update_single_repo "%TARGET_REPO%"
) else (
    call :update_folder_repos "%TARGET_FOLDER%"
)

goto :summary

:update_single_repo
set REPO_PATH=%~1

:: Check if path is relative or absolute
echo %REPO_PATH% | findstr ":" >nul
if %ERRORLEVEL% equ 0 (
    :: Absolute path
    set FULL_PATH=%REPO_PATH%
) else (
    :: Relative path - assume current directory
    set FULL_PATH=%CD%\%REPO_PATH%
)

if not exist "%FULL_PATH%" (
    echo ERROR: Repository path does not exist: %FULL_PATH%
    set /a ERROR_COUNT+=1
    goto :eof
)

call :update_repo_core "%FULL_PATH%"
goto :eof

:update_folder_repos
set FOLDER_PATH=%~1

:: Handle relative paths
if "%FOLDER_PATH%"=="." (
    set FULL_FOLDER_PATH=%CD%
) else (
    echo %FOLDER_PATH% | findstr ":" >nul
    if %ERRORLEVEL% equ 0 (
        set FULL_FOLDER_PATH=%FOLDER_PATH%
    ) else (
        set FULL_FOLDER_PATH=%CD%\%FOLDER_PATH%
    )
)

if not exist "%FULL_FOLDER_PATH%" (
    echo ERROR: Folder path does not exist: %FULL_FOLDER_PATH%
    set /a ERROR_COUNT+=1
    goto :eof
)

echo Scanning folder: %FULL_FOLDER_PATH%
echo Looking for git repositories...
echo.

for /d %%D in ("%FULL_FOLDER_PATH%\*") do (
    if exist "%%D\.git" (
        call :update_repo_core "%%D"
    )
)

goto :eof

:update_repo_core
set REPO_PATH=%~1
set REPO_NAME=%~nx1
set STASHED=0

echo [%time%] Processing: %REPO_NAME%
echo ----------------------------------
set /a PROCESSED_COUNT+=1

cd /d "%REPO_PATH%"

if not exist .git (
    echo ERROR: %REPO_NAME% is not a git repository!
    set /a ERROR_COUNT+=1
    goto :eof
)

echo Checking for local changes...
git status --porcelain > temp_status.txt 2>nul
for /f %%i in ("temp_status.txt") do set size=%%~zi
del temp_status.txt 2>nul

if !size! gtr 0 (
    echo 📦 Local changes detected. Stashing changes...
    git stash push -m "GMG Auto-stash - %date% %time%" 2>nul
    if !ERRORLEVEL! equ 0 (
        set STASHED=1
        echo ✓ Changes stashed successfully
    ) else (
        echo ❌ ERROR: Failed to stash changes for %REPO_NAME%
        set /a ERROR_COUNT+=1
        goto :eof
    )
) else (
    echo ✓ No local changes detected
)

echo 🔄 Fetching latest changes...
git fetch --all 2>nul

if !ERRORLEVEL! neq 0 (
    echo ❌ ERROR: Failed to fetch changes for %REPO_NAME%
    set /a ERROR_COUNT+=1
    goto :eof
)

echo 📍 Current branch: 
git branch --show-current

echo 📈 Pulling and rebasing latest changes...
git pull --rebase 2>nul

if !ERRORLEVEL! neq 0 (
    echo ❌ ERROR: Failed to pull/rebase changes for %REPO_NAME%
    if !STASHED! equ 1 (
        echo 🔄 Attempting to restore stashed changes...
        git stash pop 2>nul
    )
    set /a ERROR_COUNT+=1
    goto :eof
)

if !STASHED! equ 1 (
    echo 📤 Reapplying stashed changes...
    git stash pop 2>nul
    if !ERRORLEVEL! equ 0 (
        echo ✓ Stashed changes reapplied successfully
    ) else (
        echo ⚠️  WARNING: Failed to reapply stashed changes for %REPO_NAME%
        echo    Your changes are still in stash. Run 'git stash pop' manually.
    )
)

echo ✅ SUCCESS: %REPO_NAME% updated successfully

:: Show final status if there are changes
git status --porcelain > temp_status.txt 2>nul
for /f %%i in ("temp_status.txt") do set final_size=%%~zi
del temp_status.txt 2>nul

if !final_size! gtr 0 (
    echo 📋 Final repository status:
    git status --short
)

echo.
goto :eof

:summary
echo ====================================
echo GMG Summary Report
echo ====================================
echo Completion time: %date% %time%
echo Repositories processed: %PROCESSED_COUNT%

if %ERROR_COUNT% equ 0 (
    echo Status: ✅ All repositories updated successfully!
    echo.
    echo 🌅 Good Morning! All your repositories are up to date.
    echo    Have a productive day! 🚀
) else (
    echo Status: ❌ %ERROR_COUNT% repositories encountered errors
    echo.
    echo 🔍 Please check the output above for details.
    echo    You may need to resolve conflicts manually.
)

echo ====================================
echo.
exit /b %ERROR_COUNT%