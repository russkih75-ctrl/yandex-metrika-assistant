# Yandex Metrika site diagnostics (SKILL + docs/EXAMPLES.md, 10-user-intents-matrix.md)
# Token: env YANDEX_METRIKA_OAUTH_TOKEN or line in ../local.oauth.env
#   .\metrika-site-diagnostics.ps1 -CounterId 12345678
#   .\metrika-site-diagnostics.ps1 -SearchString "example.com"

param(
  [string]$CounterId,
  [string]$SearchString,
  [string]$Date1 = "30daysAgo",
  [string]$Date2 = "yesterday"
)

$ErrorActionPreference = "Stop"

$envFile = Join-Path $PSScriptRoot "..\local.oauth.env"
$loader = Join-Path $PSScriptRoot "load-yandex-oauth-env.ps1"
if ((Test-Path -LiteralPath $envFile) -and (Test-Path -LiteralPath $loader)) {
  . $loader
}

if (-not $env:YANDEX_METRIKA_OAUTH_TOKEN) {
  Write-Host "Set YANDEX_METRIKA_OAUTH_TOKEN (OAuth access_token). Add to local.oauth.env or env." -ForegroundColor Red
  exit 1
}

$base = "https://api-metrika.yandex.net"
$h = @{ Authorization = "OAuth " + $env:YANDEX_METRIKA_OAUTH_TOKEN }

function Invoke-MetrikaJson {
  param([string]$Uri)
  try {
    return Invoke-RestMethod -Uri $Uri -Headers $h -Method Get
  } catch {
    Write-Host "Request failed: $Uri" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
    throw
  }
}

$cid = $CounterId
if (-not $cid) {
  $q = if ($SearchString) { "&search_string=$([uri]::EscapeDataString($SearchString))" } else { "" }
  $list = Invoke-MetrikaJson -Uri "$base/management/v1/counters?per_page=50$q"
  if (-not $list.counters -or $list.counters.Count -eq 0) {
    Write-Host "No counters found. Use -SearchString or -CounterId." -ForegroundColor Yellow
    exit 1
  }
  Write-Host "=== Counters (first $($list.counters.Count)) ===" -ForegroundColor Cyan
  $list.counters | ForEach-Object { [PSCustomObject]@{ id = $_.id; name = $_.name; site = $_.site } } | Format-Table -AutoSize
  $cid = $list.counters[0].id
  Write-Host "Using first counter id=$cid" -ForegroundColor Green
} else {
  $one = Invoke-MetrikaJson -Uri "$base/management/v1/counter/$cid"
  Write-Host "=== Counter $cid ===" -ForegroundColor Cyan
  $one.counter | Select-Object id, name, site, status, permission | Format-List
}

Write-Host "`n=== Visits by day ($Date1 .. $Date2) ===" -ForegroundColor Cyan
$u = "$base/stat/v1/data?ids=$([uri]::EscapeDataString($cid))&dimensions=ym:s:date&metrics=ym:s:visits,ym:s:users&date1=$Date1&date2=$Date2&sort=ym:s:date&lang=ru"
Invoke-MetrikaJson -Uri $u | ConvertTo-Json -Depth 6

Write-Host "`n=== Sources (sources_summary) ===" -ForegroundColor Cyan
$u2 = "$base/stat/v1/data?ids=$([uri]::EscapeDataString($cid))&preset=sources_summary&date1=$Date1&date2=$Date2&lang=ru"
Invoke-MetrikaJson -Uri $u2 | ConvertTo-Json -Depth 6

Write-Host "`n=== Top URLs (pageviews) ===" -ForegroundColor Cyan
$u3 = "$base/stat/v1/data?ids=$([uri]::EscapeDataString($cid))&dimensions=ym:pv:URL&metrics=ym:pv:pageviews&sort=-ym:pv:pageviews&limit=15&date1=$Date1&date2=$Date2&lang=ru"
Invoke-MetrikaJson -Uri $u3 | ConvertTo-Json -Depth 6

Write-Host "`n=== Goals ===" -ForegroundColor Cyan
try {
  $goals = Invoke-MetrikaJson -Uri "$base/management/v1/counter/$cid/goals"
  $goals | ConvertTo-Json -Depth 6
} catch {
  Write-Host "(goals unavailable or no permission)" -ForegroundColor Yellow
}

Write-Host "`nDone. See docs/10-user-intents-matrix.md (sections A-E, I)." -ForegroundColor Green
