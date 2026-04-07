rem cd to directory with script
cd /d %~dp0
if "%~dp0"=="%CD%\" goto :changeddir
echo We are in %CD%. Files will be generated here.
pause
:changeddir
rem Calculate a timestamp affix
set startTime=%TIME%
rem Fix bug with hours < 10
if "%startTime:~0,1%"==" " set startTime=0%startTime:~1%
set startDate=%DATE%
set timeStamp=%startDate:~6%%startDate:~3,2%%startDate:~0,2%T%startTime:~0,2%%startTime:~3,2%%startTime:~6,2%
rem Output and errors of the following part will be logged to file
call :logged>%~n0-%COMPUTERNAME%-%timeStamp%.log 2>&1
exit /b
:logged
echo start %~n0 at %startTime% on %startDate% on %COMPUTERNAME%
set scriptName=un%~n0-%COMPUTERNAME%-%timeStamp%.bat
rem Prepare unblocking script
rem add cd to directory with script
echo cd /d %%~dp0>> %scriptName%
rem calculate a timestamp affix
echo set startTime=%%TIME%%>>%scriptName%
rem Fix bug with hours < 10 for unblock script
echo if "%%startTime:~0,1%%"==" " set startTime=0%%startTime:~1%%>>%scriptName%
echo set startDate=%%DATE%%>>%scriptName%
echo set timeStamp=%%startDate:~6,-1%%%%startDate:~3,2%%%%startDate:~0,2%%T%%startTime:~0,2%%%%startTime:~3,2%%%%startTime:~6,2%%>>%scriptName%
rem make unblocking script logging the same way as this script
echo call :logged^>%%~n0-%%COMPUTERNAME%%-%%timeStamp%%.log 2^>^&1 >>%scriptName%
echo exit /b>>%scriptName%
echo :logged>>%scriptName%
echo echo start %%~n0 at %%startTime%% on %%startDate%% on %%COMPUTERNAME%%>>%scriptName%
rem add check for computer name
echo if not "%%COMPUTERNAME%%"=="%COMPUTERNAME%" exit /b>>%scriptName%
rem Check is Windows Defender firewall running
sc query mpssvc | find ": 4  RUNNING"
if errorlevel 1 goto :starting_mpssvc
goto :check_mpssvc_config
:starting_mpssvc
echo sq stop mpssvc>>%scriptName%
sc start mpssvc
:check_mpssvc_config
sc qc mpssvc | find ": 2   AUTO_START"
if errorlevel 1 goto :check2_mpssvc_config
goto :fwconf
:check2_mpssvc_config
sc qc mpssvc | find ": 3   DEMAND_START"
if errorlevel 1 goto :check3_mpssvc_config
echo sc config mpssvc start= demand>>%scriptName%
sc config mpssvc start= auto
goto :fwconf
:check3_mpssvc_config
sc qc mpssvc | find ": 4   DISABLED"
if errorlevel 1 goto :error_unknown_config
echo sc config mpssvc start= disabled>>%scriptName%
sc config mpssvc start= auto
:error_unknown_config
echo Cannot parse start config for mpssvc
sc qc mpssvc
exit /b
:fwconf
rem Configuring Windows Defender firewall
rem Make a backup of firewall settings
netsh advfirewall export advfirewall-policy-%COMPUTERNAME%-%timeStamp%.wfw
echo netsh advfirewall import advfirewall-policy-%COMPUTERNAME%-%timeStamp%.wfw>>%scriptName%
rem Enable firewall profiles
netsh advfirewall set allprofiles state on
rem Block outbound traffic expect explicitly allowed
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
rem Delete all other rules
netsh advfirewall firewall set rule name=all new enable=no
rem Create rules
netsh advfirewall firewall add rule name="Olymp MISIS Local TCP" dir=out action=allow protocol=tcp remoteip=dns,dhcp,defaultgateway
netsh advfirewall firewall add rule name="Olymp MISIS Local UDP" dir=out action=allow protocol=udp remoteip=dns,dhcp,defaultgateway
netsh advfirewall firewall add rule name="Olymp MISIS Remote" dir=out action=allow protocol=tcp remoteip=194.58.88.173