@echo off
REM inspired by http://www.electronvector.com/blog/simple-embedded-build-environments-with-docker

REM get a unique image name based on the name of the enclosing directory
REM https://stackoverflow.com/questions/778135/how-do-i-get-the-equivalent-of-dirname-in-a-batch-file
REM https://stackoverflow.com/questions/29503925/remove-last-characters-string-batch/29504225
set BUILD_DIR=%~dp0
set temp=%BUILD_DIR%
set temp=%temp:~0,-1%
for %%F in ("%temp%") do set temp=%%~dpF
set temp=%temp:~0,-1%
for /F %%i in ("%temp%") do @set TAG_NAME=%%~ni

REM  only build the image if it isn't listed in the existing docker images
docker image ls | findstr "\<%TAG_NAME%\>" >nul
if /I "%ERRORLEVEL%" NEQ "0" (
  echo "Need to build Docker image '%TAG_NAME%'"
  docker build -t %TAG_NAME% .
) else (
  echo "Docker image '%TAG_NAME%' already exists"
)

REM Run the provided command in the environment.
docker run --mount type=bind,source="%cd%",target=/app %TAG_NAME% %args%