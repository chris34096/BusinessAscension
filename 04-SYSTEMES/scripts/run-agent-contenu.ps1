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

# Matière YAP + langage (branchement systèmes v2)
$YAP         = Get-Content "$ProjectRoot\01-MARKETING\_fondations\yap-framework.md" -Raw -Encoding UTF8
$VOC         = Get-Content "$ProjectRoot\01-MARKETING\_fondations\voc-langage-client.md" -Raw -Encoding UTF8
$SystemeIG   = Get-Content "$ProjectRoot\01-MARKETING\instagram\systeme-instagram.md" -Raw -Encoding UTF8
$SystemeLI   = Get-Content "$ProjectRoot\01-MARKETING\linkedin\systeme-linkedin.md" -Raw -Encoding UTF8

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

# Rotation tunnel TOFU/MOFU/BOFU — garantit la répartition 4/3/3 sur 10 contenus (5 runs x 2 pièces)
# Pattern (LinkedIn, Reel) sur 5 runs : (TOFU,TOFU)(MOFU,BOFU)(TOFU,MOFU)(BOFU,TOFU)(MOFU,BOFU)
# => TOFU=4 · MOFU=3 · BOFU=3
$StateDir = "$ProjectRoot\04-SYSTEMES\agents\state"
if (-not (Test-Path $StateDir)) { New-Item -ItemType Directory -Path $StateDir | Out-Null }
$CounterFile = "$StateDir\tunnel-counter.txt"
$Counter = 0
if (Test-Path $CounterFile) {
    $raw = (Get-Content $CounterFile -Raw -ErrorAction SilentlyContinue)
    if ($raw -match '^\s*(\d+)') { $Counter = [int]$Matches[1] }
}
$RunIndex = $Counter % 5
$TunnelPattern = @(
    @{ LinkedIn = "TOFU"; Reel = "TOFU" },
    @{ LinkedIn = "MOFU"; Reel = "BOFU" },
    @{ LinkedIn = "TOFU"; Reel = "MOFU" },
    @{ LinkedIn = "BOFU"; Reel = "TOFU" },
    @{ LinkedIn = "MOFU"; Reel = "BOFU" }
)
$Etages = $TunnelPattern[$RunIndex]
($Counter + 1) | Out-File $CounterFile -Encoding UTF8
Write-Host "Tunnel run $RunIndex : LinkedIn=$($Etages.LinkedIn) · Reel=$($Etages.Reel)"

# Construction du prompt complet
$Prompt = @"
$PromptBase

---

## ÉTAGES TUNNEL DU RUN (rotation 4/3/3 — impératif)
- **Post LinkedIn → étage : $($Etages.LinkedIn)**
- **Script Reel → étage : $($Etages.Reel)**
Respecte le mapping étage→CTA (yap-framework §7) : TOFU ne vend jamais · seul BOFU propose l'Audit offert · MOFU dirige vers profil/DM.

## DONNÉES INJECTÉES — $Date ($DayName) — Semaine $WeekNumber

### MOTEUR YAP (framework d'idéation + Script Builder) :
$YAP

### LANGAGE CLIENT — VOC v2 (piocher les mots EXACTS, varier) :
$VOC

### SYSTÈME INSTAGRAM (cadence + structure Reel) :
$($SystemeIG.Substring(0, [Math]::Min(3000, $SystemeIG.Length)))

### SYSTÈME LINKEDIN (5 styles YAP = 5 formats) :
$($SystemeLI.Substring(0, [Math]::Min(3000, $SystemeLI.Length)))

### CALENDRIER ÉDITORIAL :
$($Calendrier.Substring(0, [Math]::Min(2000, $Calendrier.Length)))

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
