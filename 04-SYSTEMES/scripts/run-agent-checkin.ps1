# run-agent-checkin.ps1
# Génère les messages de check-in hebdomadaires pour les clients actifs IAP™
# Planification : Task Scheduler — chaque vendredi à 15h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AgentPrompt = Join-Path $ProjectRoot "04-SYSTEMES\agents\agent-checkin-prompt.md"
$Pipeline    = Join-Path $ProjectRoot "02-SALES\pipeline-suivi.md"
$OutputDir   = Join-Path $ProjectRoot "04-SYSTEMES\agents\outputs"
$TelegramCfg = Join-Path $ProjectRoot "04-SYSTEMES\scripts\telegram-config.ps1"
$Date        = Get-Date -Format "yyyy-MM-dd"
$OutputFile  = Join-Path $OutputDir "checkin-$Date.md"

function Send-Telegram {
    param([string]$Text)
    if (Test-Path $TelegramCfg) {
        . $TelegramCfg
        $body = @{ chat_id = $TELEGRAM_CHAT_ID; text = $Text; parse_mode = "Markdown" } | ConvertTo-Json -Compress
        try {
            Invoke-RestMethod -Uri "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" `
                -Method Post -ContentType "application/json" -Body $body | Out-Null
        } catch { Write-Warning "Telegram: $_" }
    }
}

Write-Host "`n=== AGENT CHECK-IN — $Date ===" -ForegroundColor Cyan

$PipelineContent = ""
if (Test-Path $Pipeline) {
    $PipelineContent = Get-Content $Pipeline -Raw -Encoding UTF8
} else {
    Write-Warning "pipeline-suivi.md introuvable"
}

$Prompt = Get-Content $AgentPrompt -Raw -Encoding UTF8

$FullContext = @"
$Prompt

---
## DONNÉES PIPELINE (clients actifs uniquement)

$PipelineContent

---
Génère les messages de check-in pour tous les clients dont le statut contient "Actif" ou "Signé / Actif".
Si aucun client actif, réponds : "Aucun client actif cette semaine."
"@

Write-Host "Génération check-ins..." -ForegroundColor Yellow
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
$FullContext | claude --print --output-format text | Out-File -FilePath $OutputFile -Encoding UTF8

if (-not (Test-Path $OutputFile) -or (Get-Item $OutputFile).Length -eq 0) {
    Send-Telegram "*Check-in Vendredi $Date*`n`nAucun client actif détecté."
    exit 0
}

Write-Host "Check-ins sauvegardés : $OutputFile" -ForegroundColor Green

$Content = Get-Content $OutputFile -Raw -Encoding UTF8
$Message = "*Check-in Vendredi — $Date*`n`n$Content"
$Parts   = [System.Text.RegularExpressions.Regex]::Matches($Message, ".{1,3800}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($Part in $Parts) { Send-Telegram $Part.Value; Start-Sleep -Seconds 1 }

Write-Host "`n=== AGENT CHECK-IN TERMINÉ ===" -ForegroundColor Green
