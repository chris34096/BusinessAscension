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
$StripeCfg      = Join-Path $ProjectRoot "04-SYSTEMES\scripts\stripe-config.ps1"
$Date           = Get-Date -Format "yyyy-MM-dd"
$WeekNum        = Get-Date -UFormat "%V"
$OutputFile     = Join-Path $OutputDir "analytics-$Date.md"

# Charger Send-Telegram avec encodage UTF-8 correct
if (Test-Path $TelegramCfg) { . $TelegramCfg }

# Charger les helpers Stripe (lecture seule) — facultatif
if (Test-Path $StripeCfg) { . $StripeCfg }

# Construit un résumé du CA réel depuis Stripe (lecture seule).
# Robuste : toute erreur renvoie une note, l'agent ne plante jamais pour autant.
function Get-StripeSummary {
    if (-not (Get-Command Get-StripeBalance -ErrorAction SilentlyContinue)) {
        return "[Stripe non configuré — stripe-config.ps1 absent]"
    }
    try {
        $bal = Get-StripeBalance
        $dispo   = if ($bal.available) { ($bal.available[0].amount / 100.0) } else { 0 }
        $attente = if ($bal.pending)   { ($bal.pending[0].amount   / 100.0) } else { 0 }
        $devise  = if ($bal.available) { $bal.available[0].currency.ToUpper() } else { "EUR" }

        $subs = Get-StripeSubscriptions
        $nbActifs = if ($subs.data) { $subs.data.Count } else { 0 }

        # MRR estimé : chaque abonnement normalisé au mois
        $mrr = 0.0
        foreach ($s in $subs.data) {
            foreach ($it in $s.items.data) {
                $unit = $it.price.unit_amount / 100.0
                $qty  = if ($it.quantity) { $it.quantity } else { 1 }
                switch ($it.price.recurring.interval) {
                    "year"  { $mrr += ($unit * $qty) / 12.0 }
                    "week"  { $mrr += ($unit * $qty) * 4.333 }
                    "day"   { $mrr += ($unit * $qty) * 30 }
                    default { $mrr += ($unit * $qty) }   # month
                }
            }
        }

        return @"
- Solde disponible : $([math]::Round($dispo,2)) $devise
- En attente (versements à venir) : $([math]::Round($attente,2)) $devise
- Abonnements actifs (Porte 1 MRR) : $nbActifs
- MRR estimé : $([math]::Round($mrr,2)) $devise/mois
"@
    } catch {
        return "[Stripe : lecture échouée — $_]"
    }
}

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
$StripeData = Get-StripeSummary
Write-Host "CA Stripe (lecture seule) recupere."

$FullContext = "$Prompt`n`n---`n## CA REEL STRIPE (lecture seule)`n`n$StripeData`n`n---`n## KPIs DASHBOARD`n`n$Kpis`n`n---`n## OKRs DU TRIMESTRE`n`n$Okrs`n`n---`n## CALENDRIER EDITORIAL`n`n$Calendrier`n`n---`n## PIPELINE COMMERCIAL`n`n$Pipeline`n`n---`nGenere le rapport analytics complet pour la semaine $WeekNum ($Date). Utilise les chiffres CA REEL STRIPE comme source de verite pour le revenu. Tu es en mode autonome (headless) : ne pose AUCUNE question, ne propose AUCUNE option, produis directement le rapport entier maintenant."

Write-Host "Generation du rapport..."
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
$FullContext | claude --print --model haiku --output-format text | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Rapport sauvegarde : $OutputFile"

$Content = Get-Content $OutputFile -Raw -Encoding UTF8
$Message = "Analytics Semaine $WeekNum - $Date`n`n$Content"
Send-Telegram $Message

Write-Host "=== AGENT ANALYTICS TERMINE ==="