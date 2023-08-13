# Define environment variables
$env:TPL_VERSION = "v6.3.5"
$env:MPR_FILE = "ReactNativeClassDemo.mpr"
$env:JDK_PATH = "C:\progra~1\Eclipse Adoptium\jdk-11.0.16.101-hotspot"

# extract pro version
$query = @"
.mode column
.headers on
.separator ,
SELECT "_BuildVersion" FROM "_MetaData";
"@
$versionOutput = $versionOutput = $query | .\sqlite3.exe $env:MPR_FILE
$env:PRO_VERSION = ($versionOutput -split "`n")[2].Trim()

# Define paths
$originalLocation = Get-Location
$localMxHomePath = "C:\progra~1\Mendix\$($env:PRO_VERSION)"
$localMxbuildPath = "C:\progra~1\Mendix\$($env:PRO_VERSION)\modeler\mxbuild.exe"
$mxbuildPath = "mxbuild-$env:PRO_VERSION\modeler\mxbuild.exe"
$keytoolPath = Join-Path -Path $env:JDK_PATH -ChildPath "bin\keytool.exe"
$keystorePath = "native-template\android\app\temp-release-key.jks"

# Function to download file if not exists
function DownloadFileIfNotExists($url, $filePath) {
    if (-not (Test-Path -Path $filePath)) {
        Write-Host "Downloading $url to $filePath"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $filePath)
    }
}

# Use local mxbuild if exists, otherwise download
if (Test-Path -Path $localMxbuildPath) {
    $mxbuildPath = $localMxbuildPath
} else {
    Write-Host "Please install Mendix Studio Pro $env:PRO_VERSION first"
    exit 1
}

# Build Mendix project For Native
$javaHome = Join-Path -Path $env:JDK_PATH -ChildPath "bin\java.exe"
$mxbuildArgs = "--target=deploy --native-packager --loose-version-check --java-home=`"$env:JDK_PATH`" --java-exe-path=`"$javaHome`" $env:MPR_FILE"

Invoke-Expression "$mxbuildPath $mxbuildArgs"

# Clone Native Template And Copy Bundle File
if  (Test-Path -Path "native-template") {
    Write-Host "native-template exists"
}else{
    Write-Host "native-template not exists"
    git clone --depth 1 --branch $env:TPL_VERSION https://github.com/mendix/native-template.git
}
Copy-Item -Recurse -Force "deployment\native\bundle\android\*" "native-template\android\app\src\main"

# Install dependencies
Set-Location -Path "native-template"
npm install --registry=https://registry.npmmirror.com
Set-Location -Path $originalLocation

# Generate temporary keystore
$keystoreParams = "-genkey -v -keystore $keystorePath -keyalg RSA -keysize 2048 -validity 10000 -alias temp -storepass mypass -keypass mypass -dname ""CN=Temp, OU=Temp, O=Temp, L=Temp, S=Temp, C=Temp"""

Start-Process -FilePath "$keytoolPath" -ArgumentList "$keystoreParams" -Wait -WorkingDirectory $originalLocation

# Set debug signingConfig to use temporary keystore
$gradleBuildFile = "native-template\android\app\build.gradle"
(Get-Content -Path $gradleBuildFile) -replace "android {", "android {`n   signingConfigs {`n        temp {`n            storeFile file('temp-release-key.jks')`n            storePassword 'mypass'`n            keyAlias 'temp'`n            keyPassword 'mypass'`n        }`n    }" | Set-Content -Path $gradleBuildFile
(Get-Content -Path $gradleBuildFile) -replace "buildTypes {", "buildTypes {`n    debug {`n        signingConfig signingConfigs.temp`n    }" | Set-Content -Path $gradleBuildFile

# 设置要替换的内容和替换后的内容
$oldUrl = "https://maven.fabric.io/public"
$newUrl = "https://maven.aliyun.com/repository/public"

# 设置要搜索替换的文件路径（这里假设是 build.gradle 文件，您可以根据实际情况修改）
$filePath = "native-template\android\build.gradle"

# 读取文件内容
$fileContent = Get-Content -Path $filePath -Raw

# 替换内容
$newContent = $fileContent -replace [regex]::Escape($oldUrl), $newUrl

# 将新内容写回文件
$newContent | Set-Content -Path $filePath


# Build Android app
Set-Location -Path "native-template\android"
.\gradlew.bat assembleDebug

Set-Location -Path $originalLocation
