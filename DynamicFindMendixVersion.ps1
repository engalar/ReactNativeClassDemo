# ����һ���汾��
$versionNumber = "9.24.4.11007"

# ��ָ�� URL ��ȡ Mendix �汾ӳ������
$url = "https://github.com/mendix/native-template/raw/master/mendix_version.json"
$response = Invoke-RestMethod -Uri $url

# �����汾ӳ�����ݣ������������ Mendix �汾�ŵ� Native Template ��С�����汾��Ҫ��
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

# ����ҵ���������������С�����汾��Ҫ��
if ($minVersion -ne $null -and $maxVersion -ne $null) {
  Write-Host "�汾�� $versionNumber ����Ҫ�� $versionRequirement"
  Write-Host "��Ҫ��װ����С�汾��Ϊ: $minVersion"
  Write-Host "��Ҫ��װ�����汾��Ϊ: $maxVersion"

  # �� GitHub �ֿ�� Tags �б��в�������Լ��Ҫ��İ汾��ǩ
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
    Write-Host "�ҵ�����Լ��Ҫ��� Tag �汾��$matchingTags"
  }
  else {
    Write-Host "δ�ҵ�����Լ��Ҫ��� Tag �汾��"
  }
}
