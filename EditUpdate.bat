@echo off

call ListFiles MakeUpdate.bat,bin\SETTINGS.DIZ,bin\FILES.DIZ

call OpenTxtFile @%temp%\filelist.tmp
