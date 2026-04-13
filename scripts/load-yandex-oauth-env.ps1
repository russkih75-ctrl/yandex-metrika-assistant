# Loads YANDEX_* from ../local.oauth.env into current PowerShell session.
# Optional: $env:YANDEX_OAUTH_ENV_FILE = path to env file
$ErrorActionPreference = "Stop"
$path = Join-Path $PSScriptRoot "..\local.oauth.env"
if ($env:YANDEX_OAUTH_ENV_FILE) { $path = $env:YANDEX_OAUTH_ENV_FILE }
if (-not (Test-Path -LiteralPath $path)) {
  Write-Host "Missing file: $path" -ForegroundColor Red
  Write-Host "Copy local.oauth.env.example to local.oauth.env and fill in." -ForegroundColor Yellow
  exit 1
}
Get-Content -LiteralPath $path -Encoding UTF8 | ForEach-Object {
  $line = $_.Trim()
  if (-not $line -or $line.StartsWith("#")) { return }
  $i = $line.IndexOf("=")
  if ($i -lt 1) { return }
  $k = $line.Substring(0, $i).Trim()
  $v = $line.Substring($i + 1).Trim()
  if ($k) { Set-Item -Path "Env:$k" -Value $v }
}
Write-Host "OK: loaded $path" -ForegroundColor Green
