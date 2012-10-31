REM variables need to be filled out , Modify only this section
REM *****************************************************
SET VS2008DIR="C:\Program Files\Microsoft Visual Studio 9.0\Common7\IDE"
SET buildBaseDir=c:\graphviz-ms\
SET buildDir=%buildBaseDir%graphviz2\
SET targetDir=%buildBaseDir%release\
SET outputDir=c:\graphviz-ms\bin\
SET setupProjectDir=C:\graphviz-ms\graphviz-msi\setup\
SET setupProjectName=setup
SET setupProjectFile=%setupProjectDir%%setupProjectName%.sln
set sourceLibDir=c:\graphviz-ms\add-on\
set sourceUrl=http://www.graphviz.org/pub/graphviz/development/SOURCES/graphviz-working.tar.gz
set wgetPath=C:\wget\bin
set SevenzPath="C:\Program Files\7-Zip"
set pscpPath="C:\Program Files\PuTTY"
PATH=%PATH%;%VS2008DIR%;%wgetPath%;%SevenzPath%;%pscpPath%;


REM *****************************************************
REM 84716ny
REM clean up code , if you rpvode source manually comment out this section
REM *****************************************************
rmdir /S /Q %buildBaseDir%graphviz2
rmdir /S /Q %targetDir%
del %buildBaseDir%*.msi
del %buildBaseDir%*.tar
del %buildBaseDir%*.gz
del %buildBaseDir%*.gz
del %outputDir%*.exe
del %outputDir%*.dll
REM *****************************************************
REM Comment out this section to disable source download
REM *****************************************************
wget -O %buildBaseDir%source.tar.gz %sourceUrl%
7z x -y %buildBaseDir%source.tar.gz
7z x -y %buildBaseDir%source.tar
move /Y %buildBaseDir%graphviz-2.29.* graphviz2
REM **************End of source download*****************


xcopy /Y %buildDir%windows\FEATURE %buildDir%\FEATURE\ /S
xcopy /Y %sourceLibDir%GTS %buildDir%lib\GTS\ /S
xcopy /Y %sourceLibDir%release %buildBaseDir%release\ /S
xcopy /Y %sourceLibDir%gd %buildBaseDir%\graphviz2\lib\gd\
del %buildDir%libltdl\config.h /q
copy /Y %sourceLibDir%*.lib %targetDir%bin\

REM Copy few files from source tree for windows build
REM *****************************************************
copy /Y %buildDir%windows\config.h %buildDir%
copy /Y %buildDir%windows\ast_common.h %buildDir%
copy /Y %sourceLibDir%getopt.h %buildDir%
REM copy /Y %sourceLibDir%config.h %buildDir%

REM *****************************************************

REM Build release
REM *****************************************************
devenv %buildDir%graphviz.sln -Clean release
devenv %buildDir%graphviz.sln -Build release -Out %buildDir%releaseLog1
devenv %buildDir%graphviz.sln -Build release -Out %buildDir%releaseLog2
REM *****************************************************
REM Copy release outputs
REM *****************************************************
copy /Y %sourceLibDir%*.*  %targetDir%bin
copy /Y %outputDir%*.exe  %targetDir%bin
copy /Y %outputDir%dot.exe %targetDir%bin\circo.exe
copy /Y %outputDir%dot.exe %targetDir%bin\neato.exe
copy /Y %outputDir%dot.exe %targetDir%bin\fdp.exe
copy /Y %outputDir%dot.exe %targetDir%bin\twopi.exe
copy /Y %outputDir%dot.exe %targetDir%bin\sfdp.exe
copy /Y %outputDir%gv2gml.exe %targetDir%bin\gml2gv.exe
copy /Y %outputDir%*.dll  %targetDir%bin
copy /Y %outputDir%*.lib  %targetDir%lib\release\lib
copy /Y %outputDir%*.dll  %targetDir%lib\release\dll
REM *****************************************************

REM Run dot -c to generate config6 file. condig6 is shipped in the package
REM *****************************************************
%targetDir%\bin\dot -c
REM *****************************************************


REM Build debug
REM *****************************************************
devenv %buildDir%graphviz.sln -Clean debug
devenv %buildDir%graphviz.sln -Build debug -Out %buildDir%debugLog1
devenv %buildDir%graphviz.sln -Build debug -Out %buildDir%debugLog2
copy /Y %outputDir%*.lib  %targetDir%lib\debug\lib
copy /Y %outputDir%*.dll  %targetDir%lib\debug\dll
REM *****************************************************
REM del %setupProjectDir%Release\%setupProjectName%.msi
del %setupProjectDir%Release\*.msi
devenv %setupProjectFile% -Clean release -Out %buildDir%packagingLog
devenv %setupProjectFile% -Build release -Out %buildDir%packagingLog
COPY /Y %setupProjectDir%Release\%setupProjectName%.msi %buildBaseDir%graphviz-2.29.%date:~10,4%.%date:~4,2%.%date:~7,2%.msi
pscp -q *.msi graphviz-web://data/pub/graphviz/development/windows


