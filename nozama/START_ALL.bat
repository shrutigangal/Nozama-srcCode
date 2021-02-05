@ECHO OFF
START /MIN apache_start.bat
START /MIN mysql_start.bat
START smtp4dev.exe
START /MAX iexplore http://127.0.0.1