# docs内のファイルへのリンクを列挙したindex.htmlを生成するスクリプト

# このスクリプトを置いたフォルダの「直上」に docs/ がある前提
# repo_root/
#   docs/
#   tools/
#     gen_index.ps1


$docsDir = Join-Path $PSScriptRoot "..\docs"
$docsDir = (Resolve-Path $docsDir).Path  # 絶対パスに変換
$indexPath = Join-Path $docsDir "index.html"

$files = Get-ChildItem $docsDir | Where-Object { -not $_.PSIsContainer -and $_.Name -ne "index.html" } | Sort-Object Name

$html = @"
<!DOCTYPE html>
<html lang='ja'>
<head>
  <meta charset='UTF-8'>
  <title>Docs Index</title>
</head>
<body>
  <h1>Docs Index</h1>
  <ul>
"@

foreach ($f in $files) {
  $html += "    <li><a href='$($f.Name)'>$($f.Name)</a></li>`n"
}

$html += @"
  </ul>
</body>
</html>
"@

$html | Out-File -FilePath $indexPath -Encoding UTF8
Write-Host "Generated $indexPath"
