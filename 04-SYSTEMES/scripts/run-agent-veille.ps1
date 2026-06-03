# run-agent-veille.ps1
# Veille marché hebdomadaire — concurrents Instagram, LinkedIn, YouTube
# Planification : Task Scheduler — chaque dimanche à 18h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$AgentPrompt  = Join-Path $ProjectRoot "04-SYSTEMES\agents\agent-veille-prompt.md"
$SearchScript = Join-Path $PSScriptRoot "search_veille.py"
$OutputDir    = Join-Path $ProjectRoot "04-SYSTEMES\agents\outputs"
$TelegramCfg  = Join-Path $PSScriptRoot "telegram-config.ps1"
$Date         = Get-Date -Format "yyyy-MM-dd"
$WeekNum      = Get-Date -UFormat "%V"
$OutputFile   = Join-Path $OutputDir "veille-$Date.md"
$DataFile     = Join-Path $OutputDir "veille_data.json"

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

Write-Host "`n=== AGENT VEILLE — Semaine $WeekNum — $Date ===" -ForegroundColor Cyan
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

# Étape 1 : Collecte données (YouTube RSS gratuit + Exa optionnel)
Write-Host "1/3 - Collecte données concurrents..." -ForegroundColor Yellow
$ExaKey = $env:EXA_API_KEY
if ($ExaKey) {
    python $SearchScript --output $DataFile --exa-key $ExaKey
} else {
    python $SearchScript --output $DataFile
}

$VeilleData = ""
if (Test-Path $DataFile) {
    $VeilleData = Get-Content $DataFile -Raw -Encoding UTF8
} else {
    Write-Warning "Fichier veille_data.json non créé — Claude utilisera sa connaissance"
    $VeilleData = '{"date":"' + $Date + '","competitors":[],"collection_notes":{"error":"collecte Python échouée"}}'
}

# Étape 2 : Synthèse Claude
Write-Host "2/3 - Synthèse Claude..." -ForegroundColor Yellow
$Prompt = Get-Content $AgentPrompt -Raw -Encoding UTF8

$FullContext = @"
$Prompt

---
## DONNÉES COLLECTÉES CETTE SEMAINE

$VeilleData

---
Génère le rapport de veille complet pour la semaine $WeekNum ($Date).
Si des données sont manquantes, fais la synthèse avec ce qui est disponible + utilise ta connaissance des concurrents BA™ (Musy, Baer, Clouet, Hormozi, etc.) pour compléter. Indique clairement les lacunes de collecte avec une suggestion pratique.

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

# Étape 3 : Génération et sauvegarde
Write-Host "3/3 - Génération rapport..." -ForegroundColor Yellow
$FullContext | claude --print --output-format text | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Rapport veille : $OutputFile" -ForegroundColor Green

# Notification Telegram
$Content = Get-Content $OutputFile -Raw -Encoding UTF8
$Message = "*Veille Marché — Semaine $WeekNum ($Date)*`n`n$Content"
$Parts   = [System.Text.RegularExpressions.Regex]::Matches($Message, ".{1,3800}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($Part in $Parts) { Send-Telegram $Part.Value; Start-Sleep -Seconds 1 }

Write-Host "`n=== AGENT VEILLE TERMINÉ ===" -ForegroundColor Green
