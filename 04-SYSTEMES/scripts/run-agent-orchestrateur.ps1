# run-agent-orchestrateur.ps1
# Agent Orchestrateur — Business Ascension™
# Cerveau central — s'exécute chaque matin à 06h30, avant tous les autres agents

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date    = Get-Date -Format "yyyy-MM-dd"
$DayName = (Get-Date).ToString("dddd", [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR"))

Write-Host "[$Date] Agent Orchestrateur démarré..."

$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
$StateDir  = "$ProjectRoot\04-SYSTEMES\agents\state"

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
if (-not (Test-Path $StateDir))  { New-Item -ItemType Directory -Path $StateDir  | Out-Null }

# ─── LECTURE DES FICHIERS D'ÉTAT ─────────────────────────────────────────────

function Read-StateFile($path) {
    if (Test-Path $path) {
        $c = Get-Content $path -Raw -Encoding UTF8
        return $c.Substring(0, [Math]::Min(3000, $c.Length))
    }
    return "[Fichier non disponible]"
}

$StateContent  = Read-StateFile "$StateDir\content-performance.md"
$StateProspect = Read-StateFile "$StateDir\prospect-tracker.md"
$StateClients  = Read-StateFile "$StateDir\client-insights.md"

# ─── LECTURE DES DERNIERS OUTPUTS DES AGENTS ─────────────────────────────────

function Get-LatestOutput($prefix) {
    $files = Get-ChildItem "$OutputDir\$prefix-*.md" -ErrorAction SilentlyContinue |
             Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($files) {
        $c = Get-Content $files.FullName -Raw -Encoding UTF8
        return "### Dernier rapport $prefix ($($files.Name)) :`n" + $c.Substring(0, [Math]::Min(2500, $c.Length))
    }
    return "### Dernier rapport $prefix : [Aucun rapport disponible]"
}

$LastVeille    = Get-LatestOutput "veille"
$LastKPI       = Get-LatestOutput "kpi"
$LastAnalytics = Get-LatestOutput "analytics"
$LastCheckin   = Get-LatestOutput "checkin"

# ─── CONSTRUCTION DU PROMPT ──────────────────────────────────────────────────

$PromptBase = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-orchestrateur-prompt.md" -Raw -Encoding UTF8

$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date ($DayName)

### ÉTAT 1 — CONTENT PERFORMANCE :
$StateContent

---

### ÉTAT 2 — PROSPECT TRACKER :
$StateProspect

---

### ÉTAT 3 — CLIENT INSIGHTS :
$StateClients

---

### RAPPORTS AGENTS RÉCENTS :

$LastVeille

---

$LastKPI

---

$LastAnalytics

---

$LastCheckin

---

## MISSION

Analyse tous ces éléments. Applique ton processus en 5 étapes.
Génère le Daily Brief complet dans le format exact spécifié.

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

# ─── EXÉCUTION CLAUDE ─────────────────────────────────────────────────────────

Write-Host "Génération du Daily Brief..."
$BriefFile = "$StateDir\daily-brief.md"

try {
    $Response = $Prompt | claude -p --model haiku
    $Response | Out-File $BriefFile -Encoding UTF8
    Write-Host "Daily Brief écrit : $BriefFile"
} catch {
    Write-Host "ERREUR Orchestrateur : $_"
    exit 1
}

# Archive datée
$ArchiveFile = "$OutputDir\orchestrateur-$Date.md"
Copy-Item $BriefFile $ArchiveFile

# ─── NOTIFICATION TELEGRAM ───────────────────────────────────────────────────

. "$PSScriptRoot\telegram-config.ps1"
$apercu = Get-Content $BriefFile | Select-Object -First 25 | Out-String
$notif  = "ORCHESTRATEUR BA - $Date`n`n$($apercu.Substring(0, [Math]::Min(3000, $apercu.Length)))`n`nTous les agents utilisent ce brief aujourd'hui."
Send-Telegram $notif

Write-Host "[$Date] Orchestrateur terminé."
