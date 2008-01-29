@echo off
CFGFILE=%1
IF NOT "%CFGFILE%"=="-d" GOTO T1
CFGFILE=package.cfg
DEBUG=-d
GOTO doit
:T1
IF "%CFGFILE%"=="" GOTO T2
DEBUG=%2
GOTO doit
:T2
CFGFILE=package.cfg

:doit
perl %DEBUG% templates/autosub -c %CFGFILE% -c templates/system.cfg -d . -x .cfg -x \~ -x autosub -x .svn -x .dll templates
