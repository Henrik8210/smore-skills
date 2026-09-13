# Deploy SmoreSkills to the Forever AddOns folder.
# Run from repo root: .\scripts\deploy-to-wow.ps1

param(
    [string]$WowAddOns = "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$src = Join-Path $root "SmoreSkills"
$dst = Join-Path $WowAddOns "SmoreSkills"
if (-not (Test-Path $src)) {
    Write-Error "Missing SmoreSkills\"
}
if (-not (Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst | Out-Null
}
Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
$nested = Join-Path $dst "SmoreSkills"
if (Test-Path $nested) {
    Remove-Item -Path $nested -Recurse -Force
}
$toc = Join-Path $dst "SmoreSkills.toc"
$version = "?"
if (Test-Path $toc) {
    $version = (Select-String -Path $toc -Pattern "## Version: (.+)" | ForEach-Object { $_.Matches.Groups[1].Value })
}
Write-Host "Deployed SmoreSkills (v$version) -> $dst"
Write-Host "Done. /reload in game."
