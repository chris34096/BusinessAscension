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
        $url = "https://api.telegram.org/bot$TelegramToken/getUpdates?timeout=30&offset=$offset"
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
/contenu [platform] [porte] [style] - générer contenu (ex: /contenu linkedin porte1 rant)
/brief - brief quotidien : pipeline + contenu + priorité du jour
/triage [texte DM] - classifier un DM entrant (CHAUD/TIÈDE/FROID)
/followup [infos prospect] - séquence relance J+2/J+7/J+14 post-audit
/audit-prep [infos prospect] - fiche de prep Audit offert
/aide - cette aide

QUESTIONS LIBRES (exemples) :
- Génère-moi un DM pour un coach qui stagne
- Rédige un post LinkedIn sur le plafond de verre (Porte 2)
- Quelle est ma priorité cette semaine ?
- Script de relance pour un prospect en réflexion
- Prépare-moi un Audit offert pour demain
"@
                    break
                }
                # /contenu [platform] [porte] [style] [sujet optionnel]
                # ex: /contenu linkedin porte1 rant
                # ex: /contenu instagram porte2 story le plafond de verre
                { $_ -like "/contenu*" } {
                    $parts = $text -split "\s+", 5
                    $platform = if ($parts.Count -gt 1) { $parts[1] } else { "linkedin" }
                    $porte    = if ($parts.Count -gt 2) { $parts[2] } else { "porte1" }
                    $style    = if ($parts.Count -gt 3) { $parts[3] } else { "contrarian" }
                    $sujet    = if ($parts.Count -gt 4) { $parts[4] } else { "" }

                    $yapRaw = Get-Content "/home/ba/repo/01-MARKETING/_fondations/yap-framework.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                    $vocRaw = Get-Content "/home/ba/repo/01-MARKETING/_fondations/voc-langage-client.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                    $yap = if ($yapRaw) { $yapRaw.Substring(0, [Math]::Min(2500, $yapRaw.Length)) } else { "" }
                    $voc = if ($vocRaw) { $vocRaw.Substring(0, [Math]::Min(1500, $vocRaw.Length)) } else { "" }
                    $sujetLine = if ($sujet) { "Sujet/angle : $sujet" } else { "" }

                    $prompt = @"
Tu es Chris Perez, fondateur de Business Ascension. Tu generes du contenu en ta propre voix.

VOIX REGLES ABSOLUES
- Tutoiement systematique
- Premiere ligne frappe DIRECT sans intro ni presentation
- JAMAIS : liberte financiere, revenus passifs, systeme cle en main, tu merites, programme seul
- Porte 1 VOC : vivoter, decoller, le SMIC de LinkedIn, sans me cramer
- Porte 2 VOC : plafond de verre, vendre son temps, bande passante, charge mentale
- Branding : Business et Identite simultanement. Croyance en hook, JAMAIS douleur en slide 1.

YAP FRAMEWORK :
$yap

VOC CIBLE :
$voc

MISSION :
Genere un contenu $platform pour $porte, style YAP $style
$sujetLine

Tunnel : TOFU = CTA engagement uniquement jamais l'offre. MOFU = CTA profil ou DM. BOFU = Audit offert.

Genere :
1. Le contenu complet ready-to-post
2. Notes de delivery pour Reel : timing par ligne, text hook ecran
3. CTA adapte au tunnel
4. Hashtags 8 a 10

Commence DIRECTEMENT par le contenu, zero intro.
"@
                    Send-Telegram "Generation $platform ($porte - $style)..."
                    try {
                        $result = $prompt | claude -p
                        if ($result) {
                            $chunks = [System.Text.RegularExpressions.Regex]::Matches($result, ".{1,3800}", [System.Text.RegularExpressions.RegexOptions]::Singleline)
                            foreach ($c in $chunks) { Send-Telegram $c.Value; Start-Sleep -Seconds 1 }
                        } else { Send-Telegram "Pas de contenu genere. Reessaie." }
                    } catch { Send-Telegram "Erreur /contenu : $_" }
                    break
                }

                # /brief — brief quotidien pipeline + contenu a poster
                "/brief" {
                    $pipeline = Get-Content "/home/ba/repo/02-SALES/pipeline-suivi.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                    $kpis     = Get-Content "/home/ba/repo/05-FINANCE/kpis-dashboard.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                    $pipelineShort = if ($pipeline) { $pipeline.Substring(0, [Math]::Min(2000, $pipeline.Length)) } else { "Pipeline vide" }
                    $kpisShort = if ($kpis) { $kpis.Substring(0, [Math]::Min(1000, $kpis.Length)) } else { "KPIs non disponibles" }

                    $prompt = @"
Tu es l'assistant de Chris Perez, fondateur de Business Ascension. Genere son brief quotidien.

DATE : $(Get-Date -Format "dddd d MMMM yyyy")

PIPELINE :
$pipelineShort

KPIS :
$kpisShort

CADENCES CONTENU :
LinkedIn : 4 posts semaine + 2 carousels
Instagram : 2 reels + 5 stories + 1 carrousel par jour
YouTube : 1 long-form semaine + 3-4 Shorts semaine

TUNNEL YAP 4/3/3 :
TOFU (4) : croyance, education, zero vente
MOFU (3) : preuve, preuve sociale, profil
BOFU (3) : Audit offert, temoignages

Genere le brief du jour en francais, tutoiement, direct :
1. PIPELINE : 3-5 actions prioritaires avec noms de prospects
2. CONTENU A POSTER : quel format, quelle plateforme, quel etage tunnel
3. PRIORITE N1 : l'action qui genere le plus de CA aujourd'hui
4. DMS A SUIVRE : qui relancer, qui repondre
5. OBJECTIF DU JOUR : 1 chose concrete avant 18h

Max 400 mots. Direct. Actionnable.
"@
                    Send-Telegram "Generation brief du jour..."
                    try {
                        $result = $prompt | claude -p
                        if ($result) { Send-Telegram $result } else { Send-Telegram "Brief indisponible. Reessaie." }
                    } catch { Send-Telegram "Erreur /brief : $_" }
                    break
                }

                # /triage [texte du DM recu]
                { $_ -like "/triage*" } {
                    $dmText = ($text -replace "^/triage\s*", "").Trim()
                    if (-not $dmText) { Send-Telegram "Usage : /triage [texte du DM a analyser]"; break }

                    $prompt = @"
Tu es l'assistant business de Chris Perez (Business Ascension). Analyse ce DM entrant.

DM RECU :
$dmText

Reponds avec cette structure exacte :
CLASSIFICATION: CHAUD / TIEDE / FROID / CLIENT / SPAM
PORTE: 1 (0-10K) / 2 (10K-100K) / N/A
PROBLEME EXPRIME: [1 ligne]
SIGNAL D'ACHAT: oui/non + indice
ACTION RECOMMANDEE: DM de reponse / Appel / Ignorer / Relance J+X
REPONSE SUGGEREE: [1-2 phrases, voix Chris, tutoiement, question diagnostic]

Direct, pas de blabla.
"@
                    Send-Telegram "Analyse DM..."
                    try {
                        $result = $prompt | claude -p
                        if ($result) { Send-Telegram $result } else { Send-Telegram "Analyse impossible. Reessaie." }
                    } catch { Send-Telegram "Erreur /triage : $_" }
                    break
                }

                # /followup [infos prospect]
                { $_ -like "/followup*" } {
                    $info = ($text -replace "^/followup\s*", "").Trim()
                    if (-not $info) { Send-Telegram "Usage : /followup [infos prospect + nb jours depuis audit]"; break }

                    $prompt = @"
Tu es Chris Perez, fondateur de Business Ascension. Genere une sequence relance post-Audit offert.

CONTEXTE PROSPECT : $info

REGLES ABSOLUES :
- JAMAIS de pression ou countdown factice
- JAMAIS t'as pris ta decision
- Partir de quelque chose de concret (ce qu'il a dit, son business, un post recent)
- Tutoiement direct respect genereux

MESSAGE 1 (J+2) Check-in naturel :
[1-2 phrases, question ouverte, zero pression]

MESSAGE 2 (J+7) Valeur ajoutee :
[Observation utile sur son business + 1 question]

MESSAGE 3 (J+14) Derniere fenetre :
[Transparence totale, fermer la boucle proprement]

Format court. Voix Chris. Pret a copier-coller.
"@
                    Send-Telegram "Generation sequence relance..."
                    try {
                        $result = $prompt | claude -p
                        if ($result) { Send-Telegram $result } else { Send-Telegram "Sequence non generee. Reessaie." }
                    } catch { Send-Telegram "Erreur /followup : $_" }
                    break
                }

                # /audit-prep [infos prospect]
                { $_ -like "/audit-prep*" } {
                    $info = ($text -replace "^/audit-prep\s*", "").Trim()
                    if (-not $info) { Send-Telegram "Usage : /audit-prep [nom plateforme situation symptomes]"; break }

                    $scriptRaw = Get-Content "/home/ba/repo/02-SALES/script-audit-offert.md" -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                    $scriptAudit = if ($scriptRaw) { $scriptRaw.Substring(0, [Math]::Min(2000, $scriptRaw.Length)) } else { "" }

                    $prompt = @"
Tu es l'assistant de Chris Perez. Prepare la fiche de prep pour son prochain Audit offert.

INFOS PROSPECT : $info

SCRIPT AUDIT OFFERT (extrait) :
$scriptAudit

Genere la fiche de prep :

PROFIL : nom, plateforme, stade business
SYMPTOMES EXPRIMES : ce qu'il a dit
GOULOT PROBABLE : principal frein identifie
PORTE PROBABLE : 1 ou 2

QUESTIONS D'OUVERTURE (choisis 2) :
1. [question diagnostic business]
2. [question sur le frein principal]
3. [question sur ce qu'il a deja essaye]

OBJECTIONS ANTICIPEES :
- [objection] vers [reponse Chris]

PONT VERS L'OFFRE :
[Connecter son probleme a la solution sans pitcher direct]

GO si : [signaux de readiness]
NO-GO si : [signaux d'incompatibilite]

RAPPEL : Audit offert = diagnostic. On prescrit, on ne propose pas. Nom externe = Audit offert uniquement.
"@
                    Send-Telegram "Preparation Audit offert..."
                    try {
                        $result = $prompt | claude -p
                        if ($result) { Send-Telegram $result } else { Send-Telegram "Fiche non generee. Reessaie." }
                    } catch { Send-Telegram "Erreur /audit-prep : $_" }
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
