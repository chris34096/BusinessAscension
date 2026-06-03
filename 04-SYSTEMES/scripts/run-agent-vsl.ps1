# run-agent-vsl.ps1
# Pipeline VSL : VTurb API → analyse rétention → corrélation transcript → analyse Claude
# Usage avec VTurb : .\run-agent-vsl.ps1 -PlayerId "abc123" -Duration 900 -TranscriptFile "transcript_stamped.txt"
# Usage fichiers prêts : .\run-agent-vsl.ps1 -CorrelationFile "correlation.json" -TranscriptFile "transcript_stamped.txt"

param(
    [string]$PlayerId        = "",
    [int]$Duration           = 0,
    [string]$TranscriptFile  = "",
    [string]$CorrelationFile = "",
    [string]$WorkDir         = ""
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SkillDir    = Join-Path $ProjectRoot "04-SYSTEMES\skills\vsl-analyzer"
$ScriptsDir  = Join-Path $SkillDir "scripts"
$AgentPrompt = Join-Path $ProjectRoot "04-SYSTEMES\agents\agent-vsl-prompt.md"
$RefsDir     = Join-Path $SkillDir "references"
$OutputDir   = Join-Path $ProjectRoot "04-SYSTEMES\agents\outputs"
$TelegramCfg = Join-Path $ProjectRoot "04-SYSTEMES\scripts\telegram-config.ps1"
$Date        = Get-Date -Format "yyyy-MM-dd"
$OutputFile  = Join-Path $OutputDir "vsl-$Date.md"

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

Write-Host "`n=== AGENT VSL — $Date ===" -ForegroundColor Cyan

if ($WorkDir -ne "") { Set-Location $WorkDir }

# Étape 1 : VTurb API + analyse (si PlayerId fourni)
if ($PlayerId -ne "" -and $CorrelationFile -eq "") {
    if ($Duration -le 0) { Write-Error "ERROR: -Duration requis avec -PlayerId" }
    $Token = $env:VTURB_API_TOKEN
    if (-not $Token) { Write-Error "ERROR: Variable VTURB_API_TOKEN non définie" }

    Write-Host "1/4 - Récupération données VTurb..." -ForegroundColor Yellow
    python "$ScriptsDir\vturb_api.py" --token $Token --player-id $PlayerId retention `
        --video-duration $Duration --format csv --output "vturb_data_retention.csv"

    Write-Host "2/4 - Analyse rétention..." -ForegroundColor Yellow
    python "$ScriptsDir\analyze_retention.py" "vturb_data_retention.csv" --output "retention_analysis.json"

    if ($TranscriptFile -ne "" -and (Test-Path $TranscriptFile)) {
        Write-Host "3/4 - Corrélation transcript..." -ForegroundColor Yellow
        python "$ScriptsDir\correlate_transcript.py" "retention_analysis.json" $TranscriptFile `
            --language fr --output "correlation.json"
        $CorrelationFile = "correlation.json"
    } else {
        Write-Warning "Transcript non fourni — analyse sans corrélation"
        $CorrelationFile = "retention_analysis.json"
    }
}

if (-not (Test-Path $CorrelationFile)) {
    Write-Error "ERROR: Fichier de corrélation introuvable : $CorrelationFile"
}

Write-Host "4/4 - Analyse Claude en cours..." -ForegroundColor Yellow

$Prompt      = Get-Content $AgentPrompt -Raw -Encoding UTF8
$Mastery     = Get-Content "$RefsDir\copywriting-mastery.md" -Raw -Encoding UTF8
$Correlation = Get-Content $CorrelationFile -Raw -Encoding UTF8
$TranscriptContent = ""
if ($TranscriptFile -ne "" -and (Test-Path $TranscriptFile)) {
    $TranscriptContent = Get-Content $TranscriptFile -Raw -Encoding UTF8
}

$FullContext = @"
$Prompt

---
## RÉFÉRENCE COPYWRITING OBLIGATOIRE

$Mastery

---
## DONNÉES DE CORRÉLATION

$Correlation

---
## TRANSCRIPT ORIGINAL

$TranscriptContent

---
Produis l'analyse complète en 9 sections.

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
$FullContext | claude --print --output-format text | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Analyse sauvegardée : $OutputFile" -ForegroundColor Green

# Notification Telegram
$Preview = (Get-Content $OutputFile -Encoding UTF8 | Select-Object -First 15) -join "`n"
$Message = "*Agent VSL — $Date*`n`n$Preview`n`n_Analyse complète sauvegardée localement._"
$Parts = [System.Text.RegularExpressions.Regex]::Matches($Message, ".{1,3800}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($Part in $Parts) { Send-Telegram $Part.Value; Start-Sleep -Seconds 1 }

Write-Host "`n=== AGENT VSL TERMINÉ ===" -ForegroundColor Green
