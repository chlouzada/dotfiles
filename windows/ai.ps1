$codexDir = Join-Path $env:USERPROFILE ".codex"
$authFiles = @(Get-ChildItem -LiteralPath $codexDir -File -Filter "auth-*.json" | Sort-Object Name)
$lastProfilePath = Join-Path $codexDir "ai-last-profile.txt"

if ($authFiles.Count -eq 0) {
    Write-Error "No auth-*.json files were found in $codexDir"
    exit 1
}

Write-Host "Select an authentication profile:"
$lastProfile = $null
if (Test-Path -LiteralPath $lastProfilePath) {
    $lastProfile = (Get-Content -LiteralPath $lastProfilePath -Raw).Trim()
}

$defaultChoice = 0
for ($i = 0; $i -lt $authFiles.Count; $i++) {
    $marker = ""
    if ($authFiles[$i].Name -eq $lastProfile) {
        $marker = " (last used)"
        $defaultChoice = $i + 1
    }
    Write-Host ("[{0}] {1}{2}" -f ($i + 1), $authFiles[$i].Name, $marker)
}

$prompt = "Enter an option number (or 0 to cancel)"
if ($defaultChoice -gt 0) {
    $prompt += " [Enter = $defaultChoice]"
}
$selection = Read-Host $prompt
if ([string]::IsNullOrWhiteSpace($selection) -and $defaultChoice -gt 0) {
    $selection = [string]$defaultChoice
}
$choice = 0
if (-not [int]::TryParse($selection, [ref]$choice) -or $choice -lt 0 -or $choice -gt $authFiles.Count) {
    Write-Error "Invalid option."
    exit 1
}

if ($choice -eq 0) {
    Write-Host "Operation canceled."
    exit 0
}

$source = $authFiles[$choice - 1].FullName
$destination = Join-Path $codexDir "auth.json"
Copy-Item -LiteralPath $source -Destination $destination -Force
Set-Content -LiteralPath $lastProfilePath -Value $authFiles[$choice - 1].Name -NoNewline
Write-Host ("Profile {0} copied to auth.json." -f $authFiles[$choice - 1].Name)

& codex
