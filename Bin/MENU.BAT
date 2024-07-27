@echo off
if exist PosMenu.bat del PosMenu.bat
Games %1
if not exist PosMenu.bat goto SkipPos
PosMenu.bat
:SkipPos
