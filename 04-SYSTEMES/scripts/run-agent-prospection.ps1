# run-agent-prospection.ps1
# Agent Prospection — Business Ascension™
# Exécution : chaque jour ouvrable à 8h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"
$DayName = (Get-Date).ToString("dddd", [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR"))

Write-Host "[$Date] Agent Prospection démarré..."

# Dossier outputs
$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Lecture des fichiers contexte
$Pipeline    = Get-Content "$ProjectRoot\02-SALES\pipeline-suivi.md" -Raw -Encoding UTF8
$SopProspect = Get-Content "$ProjectRoot\04-SYSTEMES\sops\sop-prospection.md" -Raw -Encoding UTF8
$ColdDM      = Get-Content "$ProjectRoot\02-SALES\cold-dm-setting.md" -Raw -Encoding UTF8
$PromptBase  = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-prospection-prompt.md" -Raw -Encoding UTF8

# Construction du prompt complet
$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date ($DayName)

### PIPELINE ACTUEL :
$Pipeline

### SOP PROSPECTION :
$SopProspect

### COLD DM PLAYBOOK :
$ColdDM
"@

# Exécution claude -p
Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\prospection-$Date.md"

try {
    $Response = $Prompt | claude -p
    $Response | Out-File $OutputFile -Encoding UTF8
    Write-Host "Output sauvegarde : $OutputFile"
} catch {
    Write-Host "ERREUR : $_"
    exit 1
}

# Ouvrir dans VS Code
if (Get-Command code -ErrorAction SilentlyContinue) {
    Start-Process code $OutputFile
}

# Notification Telegram
. "$PSScriptRoot\telegram-config.ps1"
$apercu = Get-Content $OutputFile | Select-Object -First 30 | Out-String
$notif = "AGENT PROSPECTION - $Date`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Fichier complet dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent Prospection termine."
