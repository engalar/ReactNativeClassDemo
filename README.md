# config
set ws_android=C:\Users\Administrator\Desktop\NativeWS

# 构建

C://\"Program Files\"/Mendix/9.6.12.46216/modeler/mxbuild.exe --java-home="%JAVA_HOME%" --java-exe-path="%JAVA_HOME%/bin/java.exe" --target=deploy --native-packager --loose-version-check ReactNativeClassDemo.mpr

# copy bundle

if exist "%ws_android%/android/app/src/main" (xcopy "deployment/native/bundle/android" "%ws_android%/android/app/src/main" /Y /E) else echo native template not exist

start %ws_android%/android/app/src/main

# run
cd %ws_android%
npx react-native run-android --variant=DevDebug

cd android
gradlew assembleDebug

# 查看 apk

start C:\Users\Administrator\Desktop\NativeWS\android\app\build\outputs\apk\appstore\debug
