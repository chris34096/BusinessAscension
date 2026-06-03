# run-agent-analytics.ps1
# Rapport de performance hebdomadaire contenu + pipeline + KPIs
# Planification : Task Scheduler — chaque mercredi à 08h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ProjectRoot    = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AgentPrompt    = Join-Path $ProjectRoot "04-SYSTEMES\agents\agent-analytics-prompt.md"
$KpiFile        = Join-Path $ProjectRoot "05-FINANCE\kpis-dashboard.md"
$OkrFile        = Join-Path $ProjectRoot "05-FINANCE\okrs.md"
$CalendrierFile = Join-Path $ProjectRoot "01-MARKETING\instagram\calendrier-editorial.md"
$PipelineFile   = Join-Path $ProjectRoot "02-SALES\pipeline-suivi.md"
$OutputDir      = Join-Path $ProjectRoot "04-SYSTEMES\agents\outputs"
$TelegramCfg    = Join-Path $ProjectRoot "04-SYSTEMES\scripts\telegram-config.ps1"
$Date           = Get-Date -Format "yyyy-MM-dd"
$WeekNum        = Get-Date -UFormat "%V"
$OutputFile     = Join-Path $OutputDir "analytics-$Date.md"

# Charger Send-Telegram avec encodage UTF-8 correct
if (Test-Path $TelegramCfg) { . $TelegramCfg }

function Read-FileOrEmpty {
    param([string]$Path, [string]$Label)
    if (Test-Path $Path) { return Get-Content $Path -Raw -Encoding UTF8 }
    Write-Warning "$Label introuvable : $Path"
    return "[donnees non disponibles]"
}

Write-Host "=== AGENT ANALYTICS — Semaine $WeekNum — $Date ==="

$Prompt     = Get-Content $AgentPrompt -Raw -Encoding UTF8
$Kpis       = Read-FileOrEmpty $KpiFile "kpis-dashboard.md"
$Okrs       = Read-FileOrEmpty $OkrFile "okrs.md"
$Calendrier = Read-FileOrEmpty $CalendrierFile "calendrier-editorial.md"
$Pipeline   = Read-FileOrEmpty $PipelineFile "pipeline-suivi.md"

$FullContext = "$Prompt`n`n---`n## KPIs DASHBOARD`n`n$Kpis`n`n---`n## OKRs DU TRIMESTRE`n`n$Okrs`n`n---`n## CALENDRIER EDITORIAL`n`n$Calendrier`n`n---`n## PIPELINE COMMERCIAL`n`n$Pipeline`n`n---`nGenere le rapport analytics complet pour la semaine $WeekNum ($Date)."

Write-Host "Generation du rapport..."
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
$FullContext | claude --print --output-format text | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Rapport sauvegarde : $OutputFile"

$Content = Get-Content $OutputFile -Raw -Encoding UTF8
$Message = "Analytics Semaine $WeekNum - $Date`n`n$Content"
Send-Telegram $Message

Write-Host "=== AGENT ANALYTICS TERMINE ==="