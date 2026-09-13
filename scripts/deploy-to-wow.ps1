# Deploy SmoreSkills to a WoW client AddOns folder.
# Run from repo root:
#   .\scripts\deploy-to-wow.ps1 -Client anniversary
#   .\scripts\deploy-to-wow.ps1 -Client forever

param(
    [ValidateSet("anniversary", "forever")]
    [string]$Client = "anniversary",

    [string]$WowRoot = "C:\Program Files (x86)\World of Warcraft"
)

$ErrorActionPreference = "Stop"

$clientFolder = @{
    anniversary = "_anniversary_"
    forever     = "_forever_"
}

$WowAddOns = Join-Path $WowRoot ($clientFolder[$Client] + "\Interface\AddOns")

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$src = Join-Path $root "SmoreSkills"
$dst = Join-Path $WowAddOns "SmoreSkills"
if (-not (Test-Path $src)) {
    Write-Error "Missing SmoreSkills\"
}
if (-not (Test-Path $WowAddOns)) {
    Write-Error "AddOns folder not found: $WowAddOns`nInstall the $Client client first, or pass -WowRoot."
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
Write-Host "Client: $Client ($($clientFolder[$Client]))"
Write-Host "Done. /reload in game."
