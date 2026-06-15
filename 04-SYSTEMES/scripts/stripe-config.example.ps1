# stripe-config.example.ps1
# Modèle de configuration Stripe (LECTURE SEULE) — Business Ascension™
#
# USAGE :
# 1. Copier ce fichier en "stripe-config.ps1" (dans le même dossier)
# 2. Remplacer la valeur par ta clé restreinte EN LECTURE SEULE (rk_live_...)
# 3. stripe-config.ps1 est gitignored — il ne sera JAMAIS versionné
#
# ⚠️ SÉCURITÉ
# - Utilise UNIQUEMENT une clé restreinte (rk_live_) en lecture (read).
#   Jamais une clé secrète complète (sk_live_).
# - Cette clé sert à LIRE le CA / les abonnements pour les rapports agents.
#   Elle ne sert jamais à encaisser (les Payment Links buy.stripe.com font ça).
# - Si la clé fuite (chat, log, capture), régénère-la dans
#   Stripe → Developers → API keys → Restricted keys → Roll key.

# Fix encodage UTF-8 global
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$STRIPE_READ_KEY = "REMPLACER_PAR_TA_CLE_RESTREINTE_LECTURE_rk_live_..."

# Récupère le solde / les revenus via l'API Stripe (lecture seule).
function Get-StripeBalance {
    try {
        $headers = @{ Authorization = "Bearer $STRIPE_READ_KEY" }
        Invoke-RestMethod -Uri "https://api.stripe.com/v1/balance" -Headers $headers -Method Get
    } catch {
        Write-Host "Stripe erreur (balance) : $_"
    }
}

# Liste les abonnements actifs (MRR Porte 1) — lecture seule.
function Get-StripeSubscriptions {
    param([int]$Limit = 100)
    try {
        $headers = @{ Authorization = "Bearer $STRIPE_READ_KEY" }
        Invoke-RestMethod -Uri "https://api.stripe.com/v1/subscriptions?status=active&limit=$Limit" -Headers $headers -Method Get
    } catch {
        Write-Host "Stripe erreur (subscriptions) : $_"
    }
}
