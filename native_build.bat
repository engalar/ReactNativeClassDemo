@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

set ws_android=..\native-template

C://\"Program Files\"/Mendix/9.6.15.62149/modeler/mxbuild.exe --java-home="%JAVA_HOME%" --java-exe-path="%JAVA_HOME%/bin/java.exe" --target=deploy --native-packager --loose-version-check ReactNativeClassDemo.mpr

if exist "%ws_android%/android/app/src/main" (xcopy "deployment/native/bundle/android" "%ws_android%/android/app/src/main" /Y /E) else echo native template not exist

cd %ws_android%/android
gradlew.bat assembleDebug

start %ws_android%\android\app\build\outputs\apk\appstore\debug