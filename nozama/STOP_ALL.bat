@echo off
ECHO Stopping Apache Server...
call apache_stop.bat
ECHO Stopping MySQL Server...
call mysql_stop.bat
ECHO Stopping STMP Mock Service...
apache\bin\pv -f -k smtp4dev.exe -q
exit