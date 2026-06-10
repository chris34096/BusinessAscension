# run-all-agents-now.ps1
# Business Ascension™ — Lanceur manuel "tout en un"
#
# POURQUOI CE SCRIPT :
# Le CLI `claude` a besoin d'un VRAI terminal interactif. Le Planificateur de tâches
# Windows ne lui en donne pas (-> sortie vide). Ce script lance les agents dans TA
# session interactive, où `claude` fonctionne. Double-clic = tous tes agents tournent.
#
# USAGE : clic droit > Exécuter avec PowerShell (ou: lance-le depuis un terminal ouvert).
#
# NB autonomie 24/7 : nécessite soit des crédits API Anthropic (runners passés en API),
# soit un VPS avec pseudo-terminal. Voir l'état projet.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = $PSScriptRoot

# Agents à lancer à la demande (ordre logique). Les runners gèrent leur propre contexte.
$Agents = @(
    @{ Name = "KPI";          Script = "run-agent-kpi.ps1" },
    @{ Name = "Prospection";  Script = "run-agent-prospection.ps1" },
    @{ Name = "Contenu";      Script = "run-agent-contenu.ps1" },
    @{ Name = "Setting";      Script = "run-agent-setting.ps1" },
    @{ Name = "Analytics";    Script = "run-agent-analytics.ps1" },
    @{ Name = "Veille";       Script = "run-agent-veille.ps1" }
)

Write-Host ""
Write-Host "=== Business Ascension - Lancement des agents ($(Get-Date -Format 'dd/MM HH:mm')) ===" -ForegroundColor Yellow
Write-Host "Session interactive : claude fonctionne ici." -ForegroundColor DarkGray
Write-Host ""

$ok = 0; $ko = 0
foreach ($a in $Agents) {
    $path = Join-Path $ScriptDir $a.Script
    if (-not (Test-Path $path)) {
        Write-Host "[SKIP] $($a.Name) - runner introuvable ($($a.Script))" -ForegroundColor DarkYellow
        continue
    }
    Write-Host "[$($a.Name)] demarrage..." -ForegroundColor Cyan
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$($a.Name)] OK" -ForegroundColor Green
            $ok++
        } else {
            Write-Host "[$($a.Name)] code $LASTEXITCODE" -ForegroundColor Red
            $ko++
        }
    } catch {
        Write-Host "[$($a.Name)] ERREUR : $($_.Exception.Message)" -ForegroundColor Red
        $ko++
    }
    Write-Host ""
}

Write-Host "=== Termine : $ok OK - $ko en echec ===" -ForegroundColor Yellow
Write-Host "Rapports : 04-SYSTEMES\agents\outputs\  -  Dashboard : /dashboard (Telegram)" -ForegroundColor DarkGray
Write-Host "Appuie sur une touche pour fermer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
