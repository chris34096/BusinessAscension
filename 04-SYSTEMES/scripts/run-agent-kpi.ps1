# run-agent-kpi.ps1
# Agent KPI — Business Ascension™
# Exécution : chaque lundi à 7h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"
$WeekNumber = Get-Date -UFormat "%V"

Write-Host "[$Date] Agent KPI démarré — Semaine $WeekNumber..."

# Dossier outputs
$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Lecture des fichiers contexte
$Pipeline    = Get-Content "$ProjectRoot\02-SALES\pipeline-suivi.md" -Raw -Encoding UTF8
$OKRs        = Get-Content "$ProjectRoot\05-FINANCE\okrs.md" -Raw -Encoding UTF8
$KPIs        = Get-Content "$ProjectRoot\05-FINANCE\kpis-dashboard.md" -Raw -Encoding UTF8
$Budget      = Get-Content "$ProjectRoot\05-FINANCE\budget-previsionnel.md" -Raw -Encoding UTF8
$PromptBase  = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-kpi-prompt.md" -Raw -Encoding UTF8

# Output du vendredi soir précédent (si disponible)
$LastFriday = (Get-Date).AddDays(-3).ToString("yyyy-MM-dd")
$VendrediSoir = "Aucun rapport disponible pour vendredi dernier."
$VendrediFile = "$OutputDir\setting-$LastFriday.md"
if (Test-Path $VendrediFile) {
    $content = Get-Content $VendrediFile -Raw -Encoding UTF8
    $VendrediSoir = $content.Substring(0, [Math]::Min(1500, $content.Length))
}

# Construction du prompt complet
$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — Lundi $Date — Semaine $WeekNumber

### PIPELINE ACTUEL :
$Pipeline

### OKRs :
$OKRs

### KPIs DASHBOARD :
$KPIs

### BUDGET PRÉVISIONNEL (extraits) :
$($Budget.Substring(0, [Math]::Min(2000, $Budget.Length)))

### RAPPORT SETTING VENDREDI SOIR :
$VendrediSoir

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

# Exécution claude -p
Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\kpi-semaine$WeekNumber-$Date.md"

try {
    $Response = $Prompt | claude -p --model haiku
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
$notif = "RAPPORT KPI - Semaine $WeekNumber`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Rapport complet dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent KPI termine — Semaine $WeekNumber."
