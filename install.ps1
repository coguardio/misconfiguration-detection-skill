# Install the CoGuard Misconfiguration Detection skill for Claude Code
# Usage: irm https://raw.githubusercontent.com/coguardio/misconfiguration-detection-skill/master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$SkillDir = Join-Path $env:USERPROFILE ".claude\skills\misconfiguration-detection"
$ZipUrl = "https://github.com/coguardio/misconfiguration-detection-skill/releases/latest/download/misconfiguration-detection.zip"

Write-Host "Installing CoGuard Misconfiguration Detection skill..."

# Download to a temp file
$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("coguard-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null
$ZipFile = Join-Path $TmpDir "skill.zip"

try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile -UseBasicParsing

    # Extract
    Expand-Archive -Path $ZipFile -DestinationPath $TmpDir -Force

    # Install into the skills directory (clean first so stale files don't linger)
    if (Test-Path $SkillDir) {
        Remove-Item -Recurse -Force $SkillDir
    }
    New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
    Copy-Item -Recurse -Force (Join-Path $TmpDir "misconfiguration-detection\*") $SkillDir

    # Record install date so the skill doesn't check for updates right away
    $CheckFile = Join-Path $env:USERPROFILE ".claude\.coguard-skill-version-check"
    (Get-Date -Format "yyyy-MM-dd") | Set-Content $CheckFile

    Write-Host ""
    Write-Host "Installed to $SkillDir"
    Write-Host ""
    Write-Host "Restart Claude Code and type /misconfiguration-detection to use it."
}
finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
