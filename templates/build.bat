@echo off
setlocal
set CFGFILE=%1
IF NOT "%CFGFILE%"=="-d" GOTO T1
set CFGFILE=package.cfg
set DEBUG=-d
GOTO doit
:T1
IF "%CFGFILE%"=="" GOTO T2
set DEBUG=%2
GOTO doit
:T2
set CFGFILE=package.cfg

:doit
perl %DEBUG% templates/autosub -c %CFGFILE% -c templates/system.cfg -d . -x ~ templates/templates
