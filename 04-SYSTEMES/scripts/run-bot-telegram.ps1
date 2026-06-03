# run-bot-telegram.ps1
# Bot Telegram bidirectionnel — Business Ascension™
# Tu écris au bot -> Claude répond avec tout le contexte BA chargé
# Exécution : continu, démarre au login Windows

$ErrorActionPreference = "Continue"
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension" + [char]0x2122
. "$PSScriptRoot\telegram-config.ps1"

# Fix encodage sortie claude CLI
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"

function Get-BAContext {
    $pipeline = Get-Content "$ProjectRoot\02-SALES\pipeline-suivi.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $claudeMd = Get-Content "$ProjectRoot\CLAUDE.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    return @"
Tu es l'assistant personnel de Christofer Perez, fondateur de Business Ascension.
Tu as acces a tout son systeme business. Tu reponds en francais, tutoiement, voix directe.
Si la question est sur le contenu : tu generes du contenu en voix Chris.
Si la question est sur la prospection : tu generes des DMs ou des plans d'action.
Si la question est sur le business : tu analyses et prescris.
Tu es factuel, direct, sans blabla.

--- CONTEXTE PROJET ---
$($claudeMd.Substring(0, [Math]::Min(3000, $claudeMd.Length)))

--- PIPELINE ACTUEL ---
$pipeline
"@
}

Send-Telegram "Bot BA demarre. Envoie ta question ou une commande (/aide pour la liste)."

$offset = 0
Write-Host "Bot Telegram en ecoute... (Ctrl+C pour arreter)"

while ($true) {
    try {
        $url = "https://api.telegram.org/bot$TELEGRAM_TOKEN/getUpdates?timeout=30&offset=$offset"
        $updates = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 35

        foreach ($update in $updates.result) {
            $offset = $update.update_id + 1
            $message = $update.message
            if (-not $message) { continue }

            # Message vocal
            if ($message.voice) {
                Send-Telegram "Message vocal recu. En attendant la transcription automatique : ecris ta question en texte."
                continue
            }

            $text = $message.text
            if (-not $text) { continue }

            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $text"
            Send-Telegram "Traitement..."

            # Commandes rapides
            switch ($text) {
                "/pipeline" {
                    $data = Get-Content "$ProjectRoot\02-SALES\pipeline-suivi.md" -Raw -Encoding UTF8
                    Send-Telegram "PIPELINE:`n$($data.Substring(0, [Math]::Min(3500, $data.Length)))"
                    break
                }
                "/kpi" {
                    $data = Get-Content "$ProjectRoot\05-FINANCE\kpis-dashboard.md" -Raw -Encoding UTF8
                    Send-Telegram "KPIs:`n$($data.Substring(0, [Math]::Min(3500, $data.Length)))"
                    break
                }
                "/dashboard" {
                    $dashScript = Join-Path $ProjectRoot "04-SYSTEMES\scripts\run-dashboard.ps1"
                    if (Test-Path $dashScript) {
                        Send-Telegram "Génération du dashboard..."
                        try { & $dashScript } catch { Send-Telegram "Erreur dashboard : $_" }
                        Send-Telegram "Dashboard généré et ouvert dans le navigateur."
                    } else {
                        Send-Telegram "Script run-dashboard.ps1 introuvable."
                    }
                    break
                }
                "/veille" {
                    $veilleScript = Join-Path $ProjectRoot "04-SYSTEMES\scripts\run-agent-veille.ps1"
                    if (Test-Path $veilleScript) {
                        Send-Telegram "Veille marché en cours (peut prendre 2-3 minutes)..."
                        try { & $veilleScript } catch { Send-Telegram "Erreur veille : $_" }
                    } else {
                        Send-Telegram "Script run-agent-veille.ps1 introuvable."
                    }
                    break
                }
                "/checkin" {
                    $checkinScript = Join-Path $ProjectRoot "04-SYSTEMES\scripts\run-agent-checkin.ps1"
                    if (Test-Path $checkinScript) {
                        Send-Telegram "Génération des check-ins clients..."
                        try { & $checkinScript } catch { Send-Telegram "Erreur check-in : $_" }
                    } else {
                        Send-Telegram "Script run-agent-checkin.ps1 introuvable."
                    }
                    break
                }
                { $text -like "/vsl*" } {
                    $parts = $text -split " ", 3
                    $vslScript = Join-Path $ProjectRoot "04-SYSTEMES\scripts\run-agent-vsl.ps1"
                    if (-not (Test-Path $vslScript)) {
                        Send-Telegram "Script run-agent-vsl.ps1 introuvable."
                        break
                    }
                    if ($parts.Length -ge 3) {
                        $playerId = $parts[1]
                        $dur      = [int]$parts[2]
                        Send-Telegram "Analyse VSL en cours (player=$playerId, duration=$($dur)s)..."
                        try { & $vslScript -PlayerId $playerId -Duration $dur } catch { Send-Telegram "Erreur VSL : $_" }
                    } else {
                        Send-Telegram "Usage : /vsl [player_id] [duration_secondes]`nEx : /vsl abc123def456 900"
                    }
                    break
                }
                { $text -like "/objection*" } {
                    $notes = $text -replace "^/objection\s*", ""
                    if ($notes.Length -lt 10) {
                        Send-Telegram "Usage : /objection [notes de l'appel]`nEx : /objection Prospect dit trop cher, budget serré, a demandé rappel dans 2 mois"
                        break
                    }
                    $objPrompt = Join-Path $ProjectRoot "04-SYSTEMES\agents\agent-objections-prompt.md"
                    if (-not (Test-Path $objPrompt)) {
                        Send-Telegram "agent-objections-prompt.md introuvable."
                        break
                    }
                    $promptContent = Get-Content $objPrompt -Raw -Encoding UTF8
                    $fullPrompt = @"
$promptContent

---
## NOTES DE L'APPEL

$notes

---
Date : $(Get-Date -Format 'yyyy-MM-dd')
Génère la fiche objection complète en format markdown.
"@
                    Send-Telegram "Analyse de l'objection en cours..."
                    try {
                        $result = $fullPrompt | claude -p
                        $OutputDir = Join-Path $ProjectRoot "04-SYSTEMES\agents\outputs"
                        if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }
                        $outFile = Join-Path $OutputDir "objection-$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
                        $result | Out-File -FilePath $outFile -Encoding UTF8
                        $Parts = [System.Text.RegularExpressions.Regex]::Matches($result, ".{1,3800}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
                        foreach ($Part in $Parts) { Send-Telegram $Part.Value; Start-Sleep -Seconds 1 }
                        Send-Telegram "_Fiche sauvegardée : $outFile_"
                    } catch { Send-Telegram "Erreur objection : $_" }
                    break
                }
                { $_ -in "/aide", "/help" } {
                    Send-Telegram @"
COMMANDES RAPIDES :
/pipeline - pipeline actuel
/kpi - tableau de bord KPIs
/dashboard - générer le dashboard visuel
/veille - rapport veille marché + concurrents (aussi auto dimanche 18h)
/checkin - check-in clients actifs (aussi auto vendredi 15h)
/vsl [player_id] [durée_sec] - analyser une VSL VTurb
/objection [notes appel] - fiche objection depuis un appel échoué
/aide - cette aide

QUESTIONS LIBRES (exemples) :
- Génère-moi un DM pour un coach qui stagne
- Rédige un post LinkedIn sur les dents de scie
- Quelle est ma priorité cette semaine ?
- Script de relance pour un prospect en réflexion
- Prépare-moi un Audit offert pour demain
"@
                    break
                }
                default {
                    # Question libre -> Claude avec contexte BA complet
                    $context = Get-BAContext
                    $prompt = @"
$context

--- QUESTION DE CHRIS ---
$text

Reponds directement, sans introduction inutile. Droit au but.
"@
                    try {
                        $response = $prompt | claude -p
                        if ($response) {
                            Send-Telegram $response
                        } else {
                            Send-Telegram "Pas de reponse. Reessaie."
                        }
                    } catch {
                        Send-Telegram "Erreur : $_"
                    }
                }
            }
        }
    } catch {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Erreur polling : $_"
        Start-Sleep -Seconds 5
    }
}
