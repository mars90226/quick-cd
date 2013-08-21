@echo off
set TEMPFILE=moveto.bat
ruby %~dp0\moveto.rb %* > %~dp0\%TEMPFILE%
if errorlevel 10 (
	%~dp0\%TEMPFILE%
) else (
	type %~dp0\%TEMPFILE%
)
