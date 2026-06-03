# run-agent-setting.ps1
# Agent Setting — Business Ascension™
# Exécution : chaque jour ouvrable à 18h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"
$DayName = (Get-Date).ToString("dddd", [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR"))

Write-Host "[$Date] Agent Setting démarré..."

# Dossier outputs
$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Lecture des fichiers contexte
$Pipeline    = Get-Content "$ProjectRoot\02-SALES\pipeline-suivi.md" -Raw -Encoding UTF8
$SopSetting  = Get-Content "$ProjectRoot\04-SYSTEMES\sops\sop-setting.md" -Raw -Encoding UTF8
$Objections  = Get-Content "$ProjectRoot\02-SALES\objections-repertoire.md" -Raw -Encoding UTF8
$PromptBase  = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-setting-prompt.md" -Raw -Encoding UTF8

# Rapport prospection du matin (si disponible)
$ProspectionMatin = "Aucun rapport disponible pour aujourd'hui."
$ProspectionFile = "$OutputDir\prospection-$Date.md"
if (Test-Path $ProspectionFile) {
    $content = Get-Content $ProspectionFile -Raw -Encoding UTF8
    $ProspectionMatin = $content.Substring(0, [Math]::Min(1500, $content.Length))
}

# Construction du prompt complet
$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date ($DayName) — Bilan du soir

### PIPELINE ACTUEL :
$Pipeline

### SOP SETTING :
$($SopSetting.Substring(0, [Math]::Min(2000, $SopSetting.Length)))

### RÉPERTOIRE OBJECTIONS (extraits) :
$($Objections.Substring(0, [Math]::Min(2000, $Objections.Length)))

### RAPPORT PROSPECTION DU MATIN :
$ProspectionMatin

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

# Exécution claude -p
Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\setting-$Date.md"

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
$notif = "AGENT SETTING (soir) - $Date`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Fichier complet dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent Setting termine."
