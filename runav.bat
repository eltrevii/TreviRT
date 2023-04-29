@echo off
cd /d %~dp0

taskkill /f /im explorer.exe

if exist %temp%\.treviav (
	del /f /q "%temp%\.treviav"
	del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\"
	goto avmain
)

rem ---------- insertar vbs -bienvenida + confirmacion- aqui
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
echo.	box = MsgBox^(rep^(msg^),num,avname + " " + avver^)
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
echo.avver  = "v0.21 (powered by r/TronScript)"
echo.
echo.x = box^("Welcome to " + avname + ", made by aritz331_ | u/Aritz331_.\n\nDISCLAIMER:\nThis anti-virus is based on TronScript (r/TronScript), plus some extra changes that TronScript didn't have, such as correcting EXE file associations (e.g. the Axam worm).\nMore tweaks/changes might be added with time, but for now, that's the only change.\n\nDo you want to scan for threats now? This process might take, depending on your hardware, the size of the drives, the occupied space/free space (if any of them is too big), size of the files on the drive, or how big the infection is, from 15 minutes to more than a whole day. Nonetheless, it is generally recommended to leave it overnight.\n\nWARNING: This will reboot your computer (to prevent unwanted damage because of pending updates).",4+64^)
echo.if x = 6 then
echo.	WScript.echo "yes"
echo.end if
)> %temp%\treviav.vbs
rem ----------

for /f %%i in ('cscript //NOLOGO %temp%\treviav.vbs') do (set "_confirm=%%i")
if [%_confirm%]==[yes] (
	goto avreb
) else (
	exit /b
)

:avreb
type nul > %temp%\.treviav
copy "%~dpnx0" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\"
shutdown -r -t 15 -c "TreviAV needs to reboot in order to continue"
exit /b

:avmain
reg import reg\exefix.reg
call tron\tron.bat -np -a -e -sdb -m -spr -str -swu -scc
exit /b