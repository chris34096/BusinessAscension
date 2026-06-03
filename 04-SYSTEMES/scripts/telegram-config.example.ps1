# telegram-config.example.ps1
# Modèle de configuration Telegram — Business Ascension™
#
# USAGE :
# 1. Copier ce fichier en "telegram-config.ps1" (dans le même dossier)
# 2. Remplacer les valeurs ci-dessous par ton vrai token et chat_id
# 3. telegram-config.ps1 est gitignored — il ne sera jamais versionné
#
# Récupérer le token : créer un bot via @BotFather sur Telegram
# Récupérer le chat_id : envoyer un message au bot puis appeler
#   https://api.telegram.org/bot<TOKEN>/getUpdates

# Fix encodage UTF-8 global
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$TELEGRAM_TOKEN   = "REMPLACER_PAR_TON_TOKEN"
$TELEGRAM_CHAT_ID = "REMPLACER_PAR_TON_CHAT_ID"

function Send-Telegram {
    param([string]$Text)
    $maxLen = 4000
    $chunks = [Math]::Ceiling($Text.Length / $maxLen)
    for ($i = 0; $i -lt $chunks; $i++) {
        $chunk = $Text.Substring($i * $maxLen, [Math]::Min($maxLen, $Text.Length - $i * $maxLen))
        try {
            $body = @{
                chat_id = $TELEGRAM_CHAT_ID
                text    = $chunk
            }
            Invoke-RestMethod `
                -Uri "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" `
                -Method Post `
                -ContentType "application/json; charset=utf-8" `
                -Body ([System.Text.Encoding]::UTF8.GetBytes(($body | ConvertTo-Json -Compress))) | Out-Null
        } catch {
            Write-Host "Telegram erreur chunk $i : $_"
        }
    }
}
