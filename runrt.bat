@powershell -NoP -W hidden ; exit
@echo off

rem conhost check: ensures conhost.exe is used because the PowerShell window hiding method doesn't work with Windows Terminal (the window minimizes instead)
if not [%1]==[ch] (
 	start "" conhost cmd /c "%~f0" ch %*
 	exit /b
)
shift

set "_rtname=Trevi's Repair Tool | TreviRT"
set "_rtver=0.21-alpha"
set "_rtmsg=Welcome to " + rtname + " " + rtver + ", made by trevics_ | u/Aritz331_.\nThis script was made in Batch and VBScript.\n\n"

set "_msg.start=DISCLAIMER:\nThis extension is based on TronScript (r/TronScript), plus some extra changes TS didn't have, such as correcting EXE file associations (e.g. the Axam worm) and rebooting (normal mode) before proceeding.\nMore tweaks/changes will be added in the future.\n\nDo you want to scan for threats now? This process might take, depending on your hardware, the size of the drives, the occupied space/free space (if any of them is too big), size of the files on the drive, or how big the infection is, from 15 minutes to over a day. Nonetheless, it is generally recommended to leave it running overnight.\n\nWARNING: This will reboot your computer to prevent unwanted damage because of pending updates."
set "_msg.update=A new version of TreviRT is available.\nDo you want to update?"

rem reboot stuff
rem if exist %temp%\.trevirt (
	rem for /f %%i in ('type %temp%\.trevirt') do (set "_dir=%%i")
	rem del /f /q "%temp%\.trevirt"
	rem goto main
rem )

if [%~1]==[-startup] (
	call :admin
	goto :main
)

call :update

cd /d "%~dp0"

rem ---------- message box
(
echo.Set objShell = WScript.CreateObject^("WScript.Shell"^)
echo.
echo.function rep^(msg^)
echo.	rep = Replace^(msg, "\n", vbCrLf^)
echo.end function
echo.
echo.'function box^(msg, num, title^)
echo.'	box = MsgBox^(rep^(msg^),num,rep^(title^)^)
echo.'end function
echo.
echo.function box^(msg, num^)
echo.	box = MsgBox^(rep^(msg^),num,rtname + " " + rtver + " " + rtpow^)
echo.end function
echo.
echo.function pop^(msg, sec, title^)
echo.	objShell.Popup msg,sec,title
echo.end function
echo.
echo.function info^(^)
echo.	messages = _
echo.		"0 = ok" ^& _
echo.		"1 = ok, cancel" ^& _
echo.		"2 = abort, retry, ignore" ^& _
echo.		"3 = yes, no, cancel" ^& _
echo.		"4 = yes, no" ^& _
echo.		"5 = retry, cancel" ^& _
echo.		"--" ^& _
echo.		"if x = ...:" ^& _
echo.		"1 = ok" ^& _
echo.		"2 = cancel" ^& _
echo.		"3 = abort" ^& _
echo.		"4 = retry" ^& _
echo.		"5 = ignore" ^& _
echo.		"6 = yes" ^& _
echo.		"7 = no"
echo.end function
echo.
echo.rtname = "%_rtname%"
echo.rtver  = "%_rtver%"
echo.rtmsg  = "%_rtmsg%"
echo.rtpow  = "(powered by r/TronScript)"
echo.
echo.x = box^(avmsg + WScript.Arguments(0),4+64^)
echo.if x = 6 then
echo.	WScript.echo "yes"
echo.end if
)> %temp%\trtyn.vbs
rem ----------

call :tyesno "%_msg.start%"

if [%_yesno%]==[yes] (
	goto rtreb
)
exit /b

:avreb
rem echo %~dp0 > %temp%\.trevirt
rem copy "%~f0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\" >nul

(
	echo @echo off
	echo powershell start -verb runas cmd /c "%~f0" -startup
	echo del /f /q %~f0 ^& exit
) > "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\trevirt.bat"

shutdown -r -t 5 -c "TreviRT needs to reboot in order to continue. Rebooting in 5 seconds."
timeout 4 /nobreak >nul
ping localhost -n 1 >nul
taskkill /f /im explorer.exe
pause
exit /b

:main
cd /d "%_dir%"
powershell -NoP -W normal ; exit

rem delete tron stage so it starts again from scratch
del /f /q tron\resources\tron_stage.txt
del /f /q tron\resources\tron_switches.txt

reg import reg\exefix.reg
call tron\tron.bat -np -a -e -sdb -m -spr -str -swu -scc
rem del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\%~nx0"
pause
exit /b

:update
set "_url=https://raw.githubusercontent.com/eltrevii/TreviRT/main"

curl -#L "%_url%/runrt.bat" -o "%temp%\.trtupd"
fc "%~f0" "%temp%\.trtupd" || call :upddlg
exit /b

:upddlg
call :tmsg "%_msg.update%"

if [%_yesno%]==[yes] (
	start conhost cmd /c timeout 1 ^& move "%temp%\.trtupd" "%~f0" ^& call "%~f0" ch
	exit
)
exit /b

:tyesno
for /f %%i in ('cscript //NOLOGO %temp%\trtyn.vbs "%~1"') do (set "_yesno=%%i")
exit /b

:admin
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    

exit /b
