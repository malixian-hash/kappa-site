# 檢查網站資料 → commit → push → 等 GitHub Pages 建好 → 確認網站有新版本
# 用法（在網站資料夾裡）：
#   powershell -ExecutionPolicy Bypass -File tools\publish.ps1 -Message "[老師] v0.2：新增 3 月測試結果"
#   加 -CheckOnly 只檢查不發布
param(
    [string]$Message,
    [switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
$site = Split-Path $PSScriptRoot
Set-Location $site
$problems = @()

# git / gh：先找 PATH，找不到再找常見的免安裝版位置
function Find-Tool($name, $fallbacks) {
    $c = Get-Command $name -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    foreach ($f in $fallbacks) { if (Test-Path $f) { return $f } }
    return $null
}
$git = Find-Tool 'git' @("$env:USERPROFILE\KebbiDev\tools\git\cmd\git.exe")
$gh  = Find-Tool 'gh'  @("$env:USERPROFILE\KebbiDev\tools\gh\bin\gh.exe")
if (-not $env:GH_CONFIG_DIR -and (Test-Path "$env:USERPROFILE\KebbiDev\tools\gh-config")) { $env:GH_CONFIG_DIR = "$env:USERPROFILE\KebbiDev\tools\gh-config" }

Write-Host '== 1. JSON 格式 ==' -ForegroundColor Cyan
$jsonFiles = @(Get-ChildItem data, items -Filter *.json -File -ErrorAction SilentlyContinue) + @(Get-Item notes\index.json -ErrorAction SilentlyContinue)
foreach ($f in $jsonFiles) {
    $bytes = [IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        # BOM 會讓部分工具讀不到 JSON，自動拿掉
        [IO.File]::WriteAllBytes($f.FullName, $bytes[3..($bytes.Length - 1)])
        Write-Host "  已移除 BOM：$($f.Name)" -ForegroundColor Yellow
    }
    try { $null = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json; Write-Host "  OK  $($f.FullName.Substring($site.Length + 1))" }
    catch { $problems += "JSON 格式錯誤：$($f.Name)（$($_.Exception.Message.Split([char]10)[0])）" }
}

Write-Host '== 2. 內容規則 ==' -ForegroundColor Cyan
$valid = 'done', 'doing', 'blocked', 'todo'
foreach ($p in 'data\status.json', 'data\modules.json') {
    if (-not (Test-Path $p)) { continue }
    try {
        $j = Get-Content $p -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($g in @($j.goals) + @($j.components)) { if ($g -and $g.status -notin $valid) { $problems += "$p 有不合法的狀態：「$($g.status)」（$($g.title)）" } }
    } catch {}
}
foreach ($dir in 'items', 'notes') {
    # .NET 的 \w 也會配到中文，所以明確列出英數字
    Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -cnotmatch '^[A-Za-z0-9_.-]+$' } | ForEach-Object { $problems += "檔名只能用英數字與 - _ .：$dir\$($_.Name)" }
}
if (Test-Path notes\index.json) {
    $listed = (Get-Content notes\index.json -Raw -Encoding UTF8 | ConvertFrom-Json).file
    Get-ChildItem notes -Filter *.md | Where-Object { $_.Name -notin $listed } | ForEach-Object { $problems += "筆記沒有登記在 notes\index.json：$($_.Name)" }
    $listed | Where-Object { -not (Test-Path "notes\$_") } | ForEach-Object { $problems += "notes\index.json 列了不存在的檔案：$_" }
}

Write-Host '== 3. 敏感資訊 ==' -ForegroundColor Cyan
$patterns = @(
    @{ re = 'C:\\Users\\';                         why = '電腦使用者路徑' },
    @{ re = '[\w.+-]+@[\w-]+\.[\w.]+';             why = '電子郵件' },
    @{ re = '(?i)(password|passwd|密碼)\s*[:=：]';  why = '密碼' },
    @{ re = '(?i)\b(ghp|gho|github_pat|sk|AKIA)[_-]?[A-Za-z0-9]{16,}'; why = 'token / API key' },
    @{ re = '[?&](ouid|usp)=';                     why = 'Google 連結帳號參數' },
    @{ re = '\b09\d{2}-?\d{3}-?\d{3}\b';            why = '手機號碼' }
)
$scan = Get-ChildItem . -Recurse -File -Include *.json, *.md, *.html | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -ne 'AGENTS.md' -and $_.Name -ne 'README.md' }
foreach ($f in $scan) {
    $lines = Get-Content $f.FullName -Encoding UTF8
    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($p in $patterns) {
            if ($lines[$i] -match $p.re) { $problems += "可能有$($p.why)：$($f.FullName.Substring($site.Length + 1)) 第 $($i + 1) 行" }
        }
    }
}

if ($problems) {
    Write-Host "`n發現 $($problems.Count) 個問題，沒有發布：" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host '（確認不是問題的話，可以改寫內容後再試。）'
    exit 1
}
Write-Host '  沒有發現問題' -ForegroundColor Green
if ($CheckOnly) { exit 0 }

if (-not $git) { throw '找不到 git' }
if (-not $Message) { throw '請加上 -Message "[名字] v版本：說明"' }

Write-Host '== 4. 發布 ==' -ForegroundColor Cyan
& $git pull --rebase --autostash -q
& $git add -A
& $git commit -q -m $Message
if ($LASTEXITCODE -ne 0) { Write-Host '沒有新的變更需要發布'; exit 0 }
& $git push -q
$sha = (& $git rev-parse HEAD).Trim()
Write-Host "  已推送 $($sha.Substring(0, 7))"

if (-not $gh) { Write-Host '找不到 gh，略過建置確認；約 1 分鐘後自行打開網站確認。'; exit 0 }
$remote = (& $git remote get-url origin) -replace '.*github\.com[:/]', '' -replace '\.git$', ''
Write-Host '== 5. 等 GitHub Pages 建置 ==' -ForegroundColor Cyan
for ($i = 0; $i -lt 24; $i++) {
    $b = & $gh api "repos/$remote/pages/builds/latest" 2>$null | ConvertFrom-Json
    if ($b.commit -eq $sha -and $b.status -eq 'built') { break }
    if ($b.status -eq 'errored') { throw "Pages 建置失敗：$($b.error.message)" }
    Start-Sleep 5
}
$url = (& $gh api "repos/$remote/pages" --jq .html_url).Trim()
Write-Host "  建置完成：$url" -ForegroundColor Green
Write-Host "  確認新版本請開：$url?v=$($sha.Substring(0, 7))"
