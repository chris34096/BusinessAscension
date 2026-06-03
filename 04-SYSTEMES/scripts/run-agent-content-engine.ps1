# run-agent-content-engine.ps1
# Agent Content Engine — Business Ascension™
# Contenu d'attraction (skills 02-prisme + content-engine)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"

Write-Host "[$Date] Agent Content Engine démarré..."

$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

# Lecture des fichiers contexte
$Voix       = Get-Content "$ProjectRoot\01-MARKETING\_fondations\ma-voix.md" -Raw -Encoding UTF8
$Attraction = Get-Content "$ProjectRoot\01-MARKETING\contenu-attraction-prospects.md" -Raw -Encoding UTF8
$PromptBase = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-content-engine-prompt.md" -Raw -Encoding UTF8

$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date

### VOIX CHRIS (ma-voix.md) :
$Voix

### CONTENU D'ATTRACTION (référence) :
$Attraction
"@

Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\content-engine-$Date.md"

try {
    $Response = $Prompt | claude -p
    $Response | Out-File $OutputFile -Encoding UTF8
    Write-Host "Output sauvegarde : $OutputFile"
} catch {
    Write-Host "ERREUR : $_"
    exit 1
}

if (Get-Command code -ErrorAction SilentlyContinue) { Start-Process code $OutputFile }

. "$PSScriptRoot\telegram-config.ps1"
$apercu = Get-Content $OutputFile | Select-Object -First 30 | Out-String
$notif = "AGENT CONTENT ENGINE - $Date`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Fichier complet dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent Content Engine termine."
