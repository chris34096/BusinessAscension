#!/bin/bash
# watchdog.sh — Auto-surveillance du système BA™ (cron horaire sur le VPS)
# 1) Vérifie que le bot Telegram tourne — le redémarre + alerte si mort
# 2) À 19h : vérifie que les agents du jour ont produit leur output — alerte sinon
# Aucun secret dans ce fichier : le token est lu depuis telegram-config.ps1 (gitignored, présent sur le VPS uniquement)

REPO="/home/ba/repo"
OUTPUTS="$REPO/04-SYSTEMES/agents/outputs"
CONFIG="$REPO/04-SYSTEMES/scripts/telegram-config.ps1"
LOG="/home/ba/logs/watchdog.log"

# Extraire token + chat_id depuis telegram-config.ps1 (sans jamais les logger)
TOKEN=$(grep -oP '\$TelegramToken\s*=\s*"\K[^"]+' "$CONFIG" 2>/dev/null)
CHATID=$(grep -oP '\$TelegramChatId\s*=\s*"\K[^"]+' "$CONFIG" 2>/dev/null)

alert() {
  local msg="$1"
  echo "[$(date '+%F %T')] ALERTE: $msg" >> "$LOG"
  if [ -n "$TOKEN" ] && [ -n "$CHATID" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
      -d chat_id="${CHATID}" -d text="🚨 WATCHDOG BA: ${msg}" > /dev/null
  fi
}

# ── 1. Le bot est-il vivant ? ────────────────────────────────────────────
if ! systemctl is-active --quiet ba-bot.service; then
  systemctl restart ba-bot.service
  sleep 5
  if systemctl is-active --quiet ba-bot.service; then
    alert "Le bot Telegram etait mort. Redemarre automatiquement, tout est OK."
  else
    alert "Le bot Telegram est MORT et le redemarrage a ECHOUE. Intervention manuelle requise (ssh root@VPS, journalctl -u ba-bot)."
  fi
else
  echo "[$(date '+%F %T')] bot OK" >> "$LOG"
fi

# ── 2. À 19h : les agents du jour ont-ils produit ? ─────────────────────
HOUR=$(date +%H)
if [ "$HOUR" = "19" ]; then
  TODAY=$(date +%F)
  DOW=$(date +%u)   # 1=lundi ... 7=dimanche
  MISSING=""

  check() { # $1 = prefixe output, $2 = nom agent
    if ! ls "$OUTPUTS"/$1*"$TODAY"* > /dev/null 2>&1; then
      MISSING="$MISSING $2"
    fi
  }

  # Agents quotidiens en semaine
  if [ "$DOW" -le 5 ]; then
    check "prospection-" "Prospection(8h)"
    check "setting-" "Setting(18h)"
  fi
  # Contenu lun/mer/ven
  if [ "$DOW" = "1" ] || [ "$DOW" = "3" ] || [ "$DOW" = "5" ]; then
    check "contenu-" "Contenu(9h)"
  fi
  # Analytics mercredi
  [ "$DOW" = "3" ] && check "analytics-" "Analytics(8h)"
  # KPI + Checkin vendredi
  if [ "$DOW" = "5" ]; then
    check "kpi-" "KPI(17h)"
    check "checkin-" "Checkin(15h)"
  fi
  # Veille quotidienne (7h)
  check "veille-" "Veille(7h)"

  if [ -n "$MISSING" ]; then
    alert "Agents sans output aujourd'hui :$MISSING. Verifier /home/ba/logs/."
  else
    echo "[$(date '+%F %T')] outputs du jour OK" >> "$LOG"
  fi
fi
