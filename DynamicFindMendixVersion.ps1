# 给定一个版本号
$versionNumber = "9.24.4.11007"

# 从指定 URL 获取 Mendix 版本映射数据
$url = "https://github.com/mendix/native-template/raw/master/mendix_version.json"
$response = Invoke-RestMethod -Uri $url

# 解析版本映射数据，查找满足给定 Mendix 版本号的 Native Template 最小和最大版本号要求
$minVersion = $null
$maxVersion = $null

foreach ($entry in $response.PSObject.Properties) {
  $versionRequirement = $entry.Name
  $requirements = $entry.Value

  if ($versionRequirement -eq "*") {
    $minVersion = "*"
    $maxVersion = "*"
    break
  }

  if ($versionNumber -ge $versionRequirement) {
    $minVersion = $requirements.min
    $maxVersion = $requirements.max
    break
  }
}

# 如果找到了满足条件的最小和最大版本号要求
if ($minVersion -ne $null -and $maxVersion -ne $null) {
  Write-Host "版本号 $versionNumber 符合要求 $versionRequirement"
  Write-Host "需要安装的最小版本号为: $minVersion"
  Write-Host "需要安装的最大版本号为: $maxVersion"

  # 在 GitHub 仓库的 Tags 列表中查找满足约束要求的版本标签
  $repoOwner = "mendix"
  $repoName = "native-template"
  $apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/tags"
  $tags = Invoke-RestMethod -Uri $apiUrl

  $matchingTags = @()
  foreach ($tag in $tags) {
    $tagName = $tag.name
    if ($tagName -match "^v(\d+\.\d+\.\d+)(-.+)?") {
      $tagVersion = $matches[1]
      if (($minVersion -eq "*" -or [version]$tagVersion -ge [version]$minVersion) -and
                ($maxVersion -eq "*" -or [version]$tagVersion -le [version]$maxVersion)) {
        $matchingTags += $tagName
      }
    }
  }

  if ($matchingTags.Count -gt 0) {
    Write-Host "找到满足约束要求的 Tag 版本：$matchingTags"
  }
  else {
    Write-Host "未找到满足约束要求的 Tag 版本。"
  }
}
