param(
  [string]$BaseHref = "/"
)

$ErrorActionPreference = "Stop"

flutter build web --wasm --release --base-href $BaseHref

Copy-Item `
  -LiteralPath "web\.htaccess" `
  -Destination "build\web\.htaccess" `
  -Force

Write-Host "Built Flutter web release in build\web"
Write-Host "Copied web\.htaccess into build\web\.htaccess"
