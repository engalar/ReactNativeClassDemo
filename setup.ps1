$env:TPL_VERSION = "v7.0.2"

#jdk8 Path
$JDK8 = "C:\progra~1\Java\jdk1.8.0_211"
$JDK11 = "C:\progra~1\Eclipse Adoptium\jdk-11.0.16.101-hotspot"
$env:ANDROID_SDK_ROOT = "C:\Android\android-sdk"


# add sdkmanager.exe into path
$env:PATH = "$env:ANDROID_SDK_ROOT\tools\bin;$env:PATH"
$env:JAVA_HOME = $JDK8#android sdk need jdk 8
$env:PATH = "$JDK8\bin;$env:PATH"

# check choco has install android sdk
if (Get-Command sdkmanager.bat -ErrorAction SilentlyContinue) {
    Write-Host "sdkmanager.bat exists"
}
else {
    Write-Host "sdkmanager.bat not exists"
    # install choco
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    # install android sdk by choco
    choco install android-sdk -y
}
# check if build-tools and platforms has installed
if ((Test-Path -Path "$env:ANDROID_SDK_ROOT\build-tools\30.0.2" -PathType Container) -and (Test-Path -Path "$env:ANDROID_SDK_ROOT\platforms\android-31" -PathType Container)) {
    Write-Host "build-tools and platforms has installed"
}
else {
    # install build-tools and platforms
    Invoke-Expression "echo y | $env:ANDROID_HOME\tools\bin\sdkmanager.bat `"build-tools;30.0.2`" `"platforms;android-31`""
}

# but gradle need jdk 11
$env:JAVA_HOME = $JDK11
$env:PATH = (($env:PATH -split ';') | Where-Object { $_ -notlike "$JDK11\bin" } | Where-Object { $_ -notlike "$JDK8\bin" }) -join ';'
$env:PATH = "$JDK11\bin;$env:PATH"

# 打印验证信息
Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "Updated PATH:"
$env:PATH -split ';' | ForEach-Object { Write-Host "- $_" }

# find *.mpr file in current directory store fullpath into $env:MPR_FILE and print it, if not exists or more than one throw error
$env:MPR_FILE = Get-ChildItem -Path . -Filter *.mpr -Recurse | Select-Object -First 1 -ExpandProperty FullName
Write-Host  "MPR_FILE: $env:MPR_FILE"