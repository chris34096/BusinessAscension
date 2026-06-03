# run-agent-lead-intelligence.ps1
# Agent Lead Intelligence — Business Ascension™
# Prospection à l'échelle (skill lead-intelligence)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"

Write-Host "[$Date] Agent Lead Intelligence démarré..."

$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

# Lecture des fichiers contexte
$Cible      = Get-Content "$ProjectRoot\01-MARKETING\_fondations\ma-cible.md" -Raw -Encoding UTF8
$Prospect   = Get-Content "$ProjectRoot\02-SALES\prospection-outreach-2-canaux.md" -Raw -Encoding UTF8
$PromptBase = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-lead-intelligence-prompt.md" -Raw -Encoding UTF8

$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date

### ICP (ma-cible.md) :
$Cible

### CIBLAGE & SÉQUENCES :
$Prospect
"@

Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\lead-intelligence-$Date.md"

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
$notif = "AGENT LEAD INTELLIGENCE - $Date`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Fichier complet dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent Lead Intelligence termine."
