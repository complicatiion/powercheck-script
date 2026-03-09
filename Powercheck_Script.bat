@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Battery and Power Diagnostic Script

color 0A
chcp 65001 >nul

:: ------------------------------------------------------------
:: Windows Battery and Power Diagnostic Script by complicatiion
:: ------------------------------------------------------------

title Windows Battery and Power Diagnostic Script

:: --- Admin check ---
net session >nul 2>&1
if %errorlevel%==0 (
  set "ISADMIN=1"
) else (
  set "ISADMIN=0"
)

set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"
set "REPORTROOT=%USERPROFILE%\Desktop\PowerReports"
if not exist "%REPORTROOT%" md "%REPORTROOT%" >nul 2>&1

:MAIN
cls
echo ============================================================
echo.
echo        Windows Battery and Power Diagnostic Utility
echo        		    by complicatiion
echo.
if "%ISADMIN%"=="1" (
  echo                    Admin Status: YES
) else (
  echo                    Admin Status: NO
)
echo   Report Folder: %REPORTROOT%
echo ============================================================
echo.
if "%ISADMIN%"=="0" (
  echo [NOTICE] Some powercfg analyses require administrator rights.
  echo         Run this script as administrator for full functionality.
  echo.
)

echo [1] Quick status: Battery / AC / active power plan
echo [2] Full battery and power analysis
echo [3] Generate Battery Report (battery-report.html)
echo [4] Generate Energy Report (energy-report.html)   [Admin]
echo [5] Generate Sleep Study (sleepstudy.html)        [Admin / if supported]
echo [6] Check wake sources / wake timers / armed devices
echo [7] Show available standby / sleep states
echo [8] Check Hibernation / Fast Startup status
echo [9] Show power plan list and active plan
echo [A] Show power management details of network adapters
echo [B] Set power plan to "Balanced"                  [Admin]
echo [C] Enable Hibernation                            [Admin]
echo [D] Disable Hibernation                           [Admin]
echo [E] Open reports folder
echo [0] Exit
echo.
set /p CHO="Selection (0-9, A-E): "

if /I "%CHO%"=="1" goto :QUICK
if /I "%CHO%"=="2" goto :FULL
if /I "%CHO%"=="3" goto :BATTERY
if /I "%CHO%"=="4" goto :ENERGY
if /I "%CHO%"=="5" goto :SLEEPSTUDY
if /I "%CHO%"=="6" goto :WAKE
if /I "%CHO%"=="7" goto :SLEEPSTATES
if /I "%CHO%"=="8" goto :HIBERSTATUS
if /I "%CHO%"=="9" goto :PLANS
if /I "%CHO%"=="A" goto :NICDETAIL
if /I "%CHO%"=="B" goto :SETBALANCED
if /I "%CHO%"=="C" goto :HIBERON
if /I "%CHO%"=="D" goto :HIBEROFF
if /I "%CHO%"=="E" goto :OPENFOLDER
if "%CHO%"=="0" goto :END
goto :MAIN

:QUICK
cls
echo ============================================================
echo Quick Status
echo ============================================================
echo.
%PS% "Write-Host '--- System Power Status ---'; $cs = Get-CimInstance Win32_ComputerSystem; Write-Host ('Manufacturer : ' + $cs.Manufacturer); Write-Host ('Model        : ' + $cs.Model); try { $bat = Get-CimInstance Win32_Battery -ErrorAction Stop } catch { $bat = $null }; if ($bat) { foreach ($b in $bat) { Write-Host ''; Write-Host ('Battery Name : ' + $b.Name); Write-Host ('Status Code  : ' + $b.BatteryStatus); Write-Host ('Charge %%     : ' + $b.EstimatedChargeRemaining); Write-Host ('AC Power     : ' + $(if ($b.PowerOnline) {'Yes'} else {'No / Unknown'})); } } else { Write-Host ''; Write-Host 'No battery detected or battery information not available.' }; Write-Host ''; Write-Host '--- Active Power Plan ---'; powercfg /getactivescheme"
echo.
pause
goto :MAIN

:FULL
cls
echo [*] Starting full analysis...
echo.

set "STAMP=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%"
set "STAMP=%STAMP: =0%"
set "OUTFILE=%REPORTROOT%\Powercheck_%STAMP%.txt"

(
echo ============================================================
echo Battery and Power Diagnostic Report
echo Created: %DATE% %TIME%
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo ============================================================
echo.

echo [1] System Information
%PS% "Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model | Format-List"
%PS% "Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, LastBootUpTime | Format-List"
echo.

echo [2] Battery Information
%PS% "$bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; if ($bat) { $bat | Select-Object Name, DeviceID, BatteryStatus, EstimatedChargeRemaining, EstimatedRunTime, Chemistry, DesignVoltage | Format-List } else { 'No battery detected or no battery data available.' }"
echo.

echo [3] Battery Report
powercfg /batteryreport /output "%REPORTROOT%\battery-report.html" >nul 2>&1
if exist "%REPORTROOT%\battery-report.html" (
echo Battery report created: %REPORTROOT%\battery-report.html
) else (
echo Battery report could not be generated.
)

echo.
echo [4] Active Power Plan
powercfg /getactivescheme
echo.

echo [5] All Power Plans
powercfg /list
echo.

echo [6] Available Sleep States
powercfg /a
echo.

echo [7] Hibernation / Fast Startup
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled
echo.

echo [8] Last Wake Source
powercfg /lastwake
echo.

echo [9] Active Wake Timers
powercfg /waketimers
echo.

echo [10] Wake Armed Devices
powercfg /devicequery wake_armed
echo.

echo [11] Network Adapter Power Overview
%PS% "Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress | Format-Table -AutoSize"
echo.

echo [12] Advanced Adapter Power Settings
%PS% "$ad = Get-NetAdapterAdvancedProperty -AllProperties -ErrorAction SilentlyContinue; if ($ad) { $ad | Where-Object { $_.DisplayName -match 'Energy|EEE|Green|Wake|Power|Low Power|Ultra Low' } | Select-Object Name, DisplayName, DisplayValue | Format-Table -AutoSize } else { 'No advanced adapter properties available.' }"
echo.

echo [13] Energy Report
if "%ISADMIN%"=="1" (
powercfg /energy /duration 10 /output "%REPORTROOT%\energy-report.html" >nul 2>&1
if exist "%REPORTROOT%\energy-report.html" (
echo Energy report created: %REPORTROOT%\energy-report.html
) else (
echo Energy report could not be generated.
)
) else (
echo Skipped - administrator privileges required.
)

) > "%OUTFILE%" 2>&1

echo [OK] Full report saved:
echo %OUTFILE%
echo.
pause
goto :MAIN

:BATTERY
cls
echo [*] Generating battery report...
powercfg /batteryreport /output "%REPORTROOT%\battery-report.html"
echo.
if exist "%REPORTROOT%\battery-report.html" (
echo [OK] Report created:
echo %REPORTROOT%\battery-report.html
) else (
echo [NOTICE] No battery report created. This is normal on systems without a battery.
)
echo.
pause
goto :MAIN

:ENERGY
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo [*] Generating energy report (approx. 60 seconds)...
powercfg /energy /duration 60 /output "%REPORTROOT%\energy-report.html"
echo.
pause
goto :MAIN

:SLEEPSTUDY
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo [*] Generating sleep study...
powercfg /sleepstudy /output "%REPORTROOT%\sleepstudy.html"
echo.
pause
goto :MAIN

:WAKE
cls
echo ============================================================
echo Wake Analysis
echo ============================================================
echo.
echo [1] Last Wake Source
powercfg /lastwake
echo.

echo [2] Active Wake Timers
powercfg /waketimers
echo.

echo [3] Devices Allowed to Wake System
powercfg /devicequery wake_armed
echo.
pause
goto :MAIN

:SLEEPSTATES
cls
echo ============================================================
echo Available Sleep / Standby States
echo ============================================================
echo.
powercfg /a
echo.
pause
goto :MAIN

:HIBERSTATUS
cls
echo ============================================================
echo Hibernation / Fast Startup Status
echo ============================================================
echo.
powercfg /a
echo.
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled
echo.
pause
goto :MAIN

:PLANS
cls
echo ============================================================
echo Power Plans
echo ============================================================
echo.
powercfg /list
echo.
echo Active Plan:
powercfg /getactivescheme
echo.
pause
goto :MAIN

:NICDETAIL
cls
echo ============================================================
echo Network Adapter Power Management Details
echo ============================================================
echo.
%PS% "Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Select-Object Name, InterfaceDescription, Status, LinkSpeed | Format-Table -AutoSize"
echo.
%PS% "$ad = Get-NetAdapterAdvancedProperty -AllProperties -ErrorAction SilentlyContinue; if ($ad) { $ad | Where-Object { $_.DisplayName -match 'Energy|EEE|Green|Wake|Power|Low Power|Ultra Low' } | Sort-Object Name, DisplayName | Format-Table Name, DisplayName, DisplayValue -AutoSize }"
echo.
pause
goto :MAIN

:SETBALANCED
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo [*] Setting power plan to Balanced...
powercfg /setactive SCHEME_BALANCED
echo.
pause
goto :MAIN

:HIBERON
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo [*] Enabling hibernation...
powercfg /hibernate on
echo.
pause
goto :MAIN

:HIBEROFF
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo [*] Disabling hibernation...
powercfg /hibernate off
echo.
pause
goto :MAIN

:OPENFOLDER
start "" explorer.exe "%REPORTROOT%"
goto :MAIN

:NEEDADMIN
cls
echo [!] Administrator privileges required.
echo     Please run this script as administrator.
echo.
pause
goto :MAIN

:END
echo.
echo Finished. Press any key to exit...
pause
endlocal
exit /b