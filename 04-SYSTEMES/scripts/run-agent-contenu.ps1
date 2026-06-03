# run-agent-contenu.ps1
# Agent Contenu — Business Ascension™
# Exécution : lundi, mercredi, vendredi à 9h00

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension™"
$Date = Get-Date -Format "yyyy-MM-dd"
$DayName = (Get-Date).ToString("dddd", [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR"))
$WeekNumber = Get-Date -UFormat "%V"

Write-Host "[$Date] Agent Contenu démarré..."

# Dossier outputs
$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Lecture des fichiers contexte
$Calendrier  = Get-Content "$ProjectRoot\01-MARKETING\instagram\calendrier-editorial.md" -Raw -Encoding UTF8
$VoixChris   = Get-Content "$ProjectRoot\01-MARKETING\_fondations\ma-voix.md" -Raw -Encoding UTF8
$PromptBase  = Get-Content "$ProjectRoot\04-SYSTEMES\agents\agent-contenu-prompt.md" -Raw -Encoding UTF8

# Sélectionner un Value Asset selon le jour de la semaine (rotation)
$DayOfWeek = (Get-Date).DayOfWeek.value__
$ValueAssets = @(
    "value-asset-01-vraie-raison-stagnation.md",
    "value-asset-02-formations-ne-suffisent-pas.md",
    "value-asset-03-mois-12000-mois-zero.md",
    "value-asset-04-business-operating-system-6-poles.md",
    "value-asset-05-don-quichotte-entrepreneur.md",
    "value-asset-06-switch-chiffre-affaires.md"
)
$VAIndex = $DayOfWeek % $ValueAssets.Count
$VAFile = "$ProjectRoot\01-MARKETING\value-assets\$($ValueAssets[$VAIndex])"
$ValueAsset = "Aucun Value Asset disponible pour aujourd'hui."
if (Test-Path $VAFile) {
    $content = Get-Content $VAFile -Raw -Encoding UTF8
    $ValueAsset = $content.Substring(0, [Math]::Min(2000, $content.Length))
}

# Construction du prompt complet
$Prompt = @"
$PromptBase

---

## DONNÉES INJECTÉES — $Date ($DayName) — Semaine $WeekNumber

### CALENDRIER ÉDITORIAL :
$($Calendrier.Substring(0, [Math]::Min(3000, $Calendrier.Length)))

### VOIX ET STYLE DE CHRIS :
$($VoixChris.Substring(0, [Math]::Min(2000, $VoixChris.Length)))

### VALUE ASSET DE RÉFÉRENCE DU JOUR :
$ValueAsset

---

## EXECUTE MAINTENANT
Tu es en mode autonome (headless). Produis DIRECTEMENT le livrable complet au format defini ci-dessus. Ne pose AUCUNE question, ne propose AUCUNE option. Genere tout, maintenant.
"@

# Exécution claude -p
Write-Host "Envoi à Claude..."
$OutputFile = "$OutputDir\contenu-$Date.md"

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
$notif = "AGENT CONTENU - $Date`n`n$($apercu.Substring(0, [Math]::Min(3500, $apercu.Length)))`n`n-- Post LinkedIn + Script Reel complets dans VS Code."
Send-Telegram $notif

Write-Host "[$Date] Agent Contenu termine."
