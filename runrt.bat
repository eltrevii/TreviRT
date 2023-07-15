@powershell -NoP -W hidden ; exit
@echo off

rem conhost check: ensures conhost.exe is used because the PowerShell window hiding method doesn't work with Windows Terminal (the window minimizes instead)
if not [%~1]==[ch] (
 	start "" conhost cmd /c "%~f0" ch
 	exit /b
)
shift

set "_avname=TreviAV"
set "_avver=0.12"
set "_avmsg=Welcome to " + avname + " " + avver + ", made by aritz331_ | u/Aritz331_.\nThis script was made in Batch and VBScript.\n\n"

rem reboot stuff
rem if exist %temp%\.treviav (
	rem for /f %%i in ('type %temp%\.treviav') do (set "_dir=%%i")
	rem del /f /q "%temp%\.treviav"
	rem goto avmain
rem )

if [%~1]==[-startup] (
	call :admin
	goto :avmain
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
echo.	box = MsgBox^(rep^(msg^),num,avname + " " + avver + " " + avpow^)
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
echo.avname = "%_avname%"
echo.avver  = "%_avver%"
echo.avmsg  = "%_avmsg%"
echo.avpow  = "(powered by r/TronScript)"
echo.
echo.x = box^(avmsg ^& WScript.Arguments(0),4+64^)
echo.if x = 6 then
echo.	WScript.echo "yes"
echo.end if
)> %temp%\trtyesno.vbs
rem ----------

for /f %%i in ('cscript //NOLOGO %temp%\trtyesno.vbs "DISCLAIMER:\nThis extension is based on TronScript (r/TronScript), plus some extra changes that TronScript didn't have, such as correcting EXE file associations (e.g. the Axam worm).\nMore tweaks/changes might be added with time, but for now, that's the only change.\n\nThere's an extra feature which is to reboot before proceeding. TronScript does have a parameter to reboot, but it doesn't start after rebooting (because it only allows to reboot to Safe Mode).\n\nDo you want to scan for threats now? This process might take, depending on your hardware, the size of the drives, the occupied space/free space (if any of them is too big), size of the files on the drive, or how big the infection is, from 15 minutes to more than a whole day. Nonetheless, it is generally recommended to leave it overnight.\n\nWARNING: This will reboot your computer (to prevent unwanted damage because of pending updates)."') do (set "_confirm=%%i")

if [%_confirm%]==[yes] (
	goto avreb
)
exit /b

:avreb
rem echo %~dp0 > %temp%\.treviav
rem copy "%~f0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\" >nul

(
	echo @echo off
	echo powershell start -verb runas cmd /c "%~f0" -startup
	echo del /f /q %~f0
	echo exit
) > "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\trevirt.bat"

shutdown -r -t 5 -c "TreviAV needs to reboot in order to continue. Rebooting in 5 seconds."
timeout 4 /nobreak >nul
ping localhost -n 1 >nul
taskkill /f /im explorer.exe
pause
exit /b

:avmain
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
set "_url=https://raw.githubusercontent.com/aritz331/TreviAV/main"

curl -#L "%_url%/runrt.bat" -o "%temp%\.trtupd"
fc "%~f0" "%temp%\.trtupd" || call :upddiag
exit /b

:upddiag
for /f %%i in ('cscript //NOLOGO %temp%\trtyesno.vbs') do (set "_updc=%%i")

if [%_updc%]==[yes] (
	start conhost cmd /c timeout 1 ^& move "%temp%\.trtupd" "%~f0" ^& call "%~f0" ch
	exit
)
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