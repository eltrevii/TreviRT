@powershell -NoP -W hidden ; exit
@echo off

rem conhost check: ensures conhost.exe is used because the PowerShell window hiding method doesn't work with Windows Terminal (the window minimizes instead)
if not [%~1]==[ch] (
 	start "" conhost cmd /c "%~dpnx0" ch
 	exit /b
)

rem reboot stuff
if exist %temp%\.treviav (
	for /f %%i in ('type %temp%\.treviav') do (set "_dir=%%i")
	del /f /q "%temp%\.treviav"
	goto avmain
)

cd /d %_dir%

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
echo.avname = "TreviAV"
echo.avver  = "v0.23"
echo.avpow  = "(powered by r/TronScript)"
echo.
echo.x = box^("Welcome to " + avname + " " + avver + ", made by aritz331_ | u/Aritz331_.\n\nDISCLAIMER:\nThis anti-virus is based on TronScript (r/TronScript), plus some extra changes that TronScript didn't have, such as correcting EXE file associations (e.g. the Axam worm).\nMore tweaks/changes might be added with time, but for now, that's the only change.\n\nThere's an extra feature which is to reboot before proceeding. TronScript does have a parameter to reboot, but it doesn't start after rebooting.\n\nDo you want to scan for threats now? This process might take, depending on your hardware, the size of the drives, the occupied space/free space (if any of them is too big), size of the files on the drive, or how big the infection is, from 15 minutes to more than a whole day. Nonetheless, it is generally recommended to leave it overnight.\n\nWARNING: This will reboot your computer (to prevent unwanted damage because of pending updates).",4+64^)
echo.if x = 6 then
echo.	WScript.echo "yes"
echo.end if
)> %temp%\treviav.vbs
rem ----------

for /f %%i in ('cscript //NOLOGO %temp%\treviav.vbs') do (set "_confirm=%%i")
del /f /q %temp%\treviav.vbs
if [%_confirm%]==[yes] (
	goto avreb
)
exit /b

:avreb
echo %~dp0 > %temp%\.treviav
copy "%~dpnx0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\" >nul
shutdown -r -t 5 -c "TreviAV needs to reboot in order to continue. Rebooting in 5 seconds."
timeout 4 /nobreak >nul
ping localhost -n 1 >nul
taskkill /f /im explorer.exe
pause
exit /b

:avmain
powershell -NoP -W normal ; exit
reg import reg\exefix.reg
call tron\tron.bat -np -a -e -sdb -m -spr -str -swu -scc
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\%~nx0"
pause
exit /b