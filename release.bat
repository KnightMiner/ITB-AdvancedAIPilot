@echo off

IF EXIST build RMDIR /q /s build
IF EXIST "Chess-Pawns-#.#.#.zip" DEL "Advanced-AI-Pilot-#.#.#.zip"
MKDIR build
MKDIR build\AdvancedAIPilot

REM Copy required files into build directory
XCOPY img build\AdvancedAIPilot\img /s /e /i
XCOPY scripts build\AdvancedAIPilot\scripts /s /e /i

REM Zipping contents
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('build', 'Advanced-AI-Pilot-#.#.#.zip'); }"

REM Removing build directory
RMDIR /q /s build
