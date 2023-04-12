# 图形构建方式
[https://mendix.bbscloud.com/info/0f954ae8cc6f4d6db66a8744483161a4?csr=1](https://mendix.bbscloud.com/info/0f954ae8cc6f4d6db66a8744483161a4?csr=1)
# 下载原生应用构建模板备用
git clone https://github.com/mendix/native-template/tree/v6.2.29
set ws_android=..\native-template

# 构建js bundle文件
<!-- mxbuild-9.6.15.62149.tar.gz\mxbuild-9.6.15.62149.tar\modeler\x86\ -->
<!-- https://cdn.mendix.com/runtime/mxbuild-9.6.15.62149.tar.gz -->

C://\"Program Files\"/Mendix/9.6.15.62149/modeler/mxbuild.exe --java-home="%JAVA_HOME%" --java-exe-path="%JAVA_HOME%/bin/java.exe" --target=deploy --native-packager --loose-version-check ReactNativeClassDemo.mpr

# 复制 bundle

if exist "%ws_android%/android/app/src/main" (xcopy "deployment/native/bundle/android" "%ws_android%/android/app/src/main" /Y /E) else echo native template not exist

start %ws_android%/android/app/src/main

# 构建准备工作
cd %ws_android%
npm i

# 直接运行模拟器
npx react-native run-android --variant=DevDebug

# 构建mpk文件
cd android
./gradlew assembleDebug

# 查看 apk

start %ws_android%\android\app\build\outputs\apk\appstore\debug
