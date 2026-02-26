@echo off

setlocal EnableDelayedExpansion

REM Set base path for Program Files (x86)
set "BASE=%ProgramFiles(x86)%"
set "ADDON=ProfessionMaster"
set "SRC=%~dp0"

REM List of WoW folders
set FOLDERS=_anniversary_ _classic_ _classic_era_


for %%F in (%FOLDERS%) do call :deploy "%%F"

goto :eof


:deploy
setlocal EnableDelayedExpansion
set "FOLDER=%~1"
set "TARGET=%BASE%\World of Warcraft\%FOLDER%\Interface\AddOns\%ADDON%"
if exist "!TARGET!" (
    echo Removing !TARGET! ...
    rmdir /S /Q "!TARGET!"
)
echo Creating !TARGET! ...
mkdir "!TARGET!"
echo Copying to !TARGET! ...
set "ROBO_SRC=!SRC!"
if "!ROBO_SRC:~-1!"=="\" set "ROBO_SRC=!ROBO_SRC:~0,-1!"
robocopy !ROBO_SRC! "!TARGET!" /MIR /XD .git /XF deploy-addon.bat
endlocal
exit /b

endlocal
pause
