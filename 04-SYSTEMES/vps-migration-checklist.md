# Checklist Migration VPS Hetzner — Business Ascension™
> Mercredi 28/05/2026 — 10h00
> Durée estimée : 3h30 au total
> VPS : Hetzner CX21 (2 vCPU / 4 GB RAM / 40 GB SSD) — ~4,50€/mois

---

## AVANT LE JOUR J — À FAIRE MAINTENANT

- [ ] Commander le VPS sur hetzner.com → Project > Add Server → CX21 → Ubuntu 24.04 LTS
- [ ] Générer une clé SSH locale : `ssh-keygen -t ed25519 -C "ba-vps"`
- [ ] Ajouter la clé publique au VPS lors de la commande
- [ ] Récupérer l'IP publique du VPS (dashboard Hetzner)
- [ ] Préparer les variables d'environnement dans un bloc-notes (hors dépôt) :
  - `ANTHROPIC_API_KEY`
  - `TELEGRAM_TOKEN`
  - `TELEGRAM_CHAT_ID`
  - `SUPABASE_URL` + `SUPABASE_KEY` (après création Supabase)
- [ ] Créer le projet Supabase sur supabase.com (free tier)
- [ ] Copier les schémas SQL depuis `supabase-architecture.md` → créer les tables

---

## ÉTAPE 1 — Connexion et sécurisation (~20 min)

```bash
# Connexion initiale
ssh root@[IP_VPS]

# Mise à jour système
apt update && apt upgrade -y

# Créer utilisateur dédié
adduser ba
usermod -aG sudo ba

# Copier la clé SSH vers le nouvel utilisateur
rsync --archive --chown=ba:ba ~/.ssh /home/ba

# Firewall : SSH + HTTPS uniquement
ufw allow OpenSSH
ufw allow 443/tcp
ufw enable

# Vérifier
ufw status
```

---

## ÉTAPE 2 — Installation des dépendances (~40 min)

```bash
# Basculer vers l'utilisateur ba
su - ba

# Python 3.11 + pip
sudo apt install -y python3.11 python3-pip python3.11-venv

# Node.js 20 LTS (pour Claude CLI)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Vérifier versions
python3 --version    # 3.11.x
node --version       # v20.x.x

# Claude CLI
npm install -g @anthropic/claude-code
claude --version

# Bibliothèques Python
pip install supabase python-telegram-bot requests feedparser
```

---

## ÉTAPE 3 — Variables d'environnement (~10 min)

```bash
# Fichier .env (jamais versionné)
nano /home/ba/.env

# Contenu :
ANTHROPIC_API_KEY=sk-ant-...
TELEGRAM_TOKEN=...
TELEGRAM_CHAT_ID=...
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_KEY=eyJ...

# Charger dans le shell
echo 'set -a; source /home/ba/.env; set +a' >> /home/ba/.bashrc
source /home/ba/.bashrc

# Vérifier
echo $ANTHROPIC_API_KEY
```

---

## ÉTAPE 4 — Transfert des fichiers (~30 min)

Depuis le PC Windows, ouvrir PowerShell :

```powershell
$VPS_IP = "[IP_VPS]"
$LOCAL_ROOT = "E:\Document\VS CODE\Marketing\Business Ascension" + [char]0x2122
$REMOTE = "ba@${VPS_IP}:/home/ba/ba"

# Créer les dossiers sur le VPS
ssh ba@$VPS_IP "mkdir -p /home/ba/ba/agents /home/ba/ba/scripts /home/ba/ba/logs"

# Transférer les prompts agents
scp "$LOCAL_ROOT\04-SYSTEMES\agents\agent-veille-prompt.md" "${REMOTE}/agents/"
scp "$LOCAL_ROOT\04-SYSTEMES\agents\agent-checkin-prompt.md" "${REMOTE}/agents/"
scp "$LOCAL_ROOT\04-SYSTEMES\agents\agent-analytics-prompt.md" "${REMOTE}/agents/"
scp "$LOCAL_ROOT\04-SYSTEMES\agents\agent-objections-prompt.md" "${REMOTE}/agents/"
scp "$LOCAL_ROOT\04-SYSTEMES\agents\agent-vsl-prompt.md" "${REMOTE}/agents/"

# Transférer le script veille Python
scp "$LOCAL_ROOT\04-SYSTEMES\scripts\search_veille.py" "${REMOTE}/scripts/"
```

---

## ÉTAPE 5 — Bot Telegram en Webhook (~45 min)

Le bot passe du polling (actuel, besoin du PC allumé) au webhook (VPS 24/7, instantané).

### 5a — Nginx + certificat SSL

```bash
sudo apt install -y nginx certbot python3-certbot-nginx

# Vérifier que l'IP est accessible (sans domaine, on utilise l'IP directement)
# Option A : domaine (recommandé si tu en as un)
# Option B : IP avec certificat auto-signé (bot Telegram accepte)

# Avec domaine (ex: ba.christoferperez.com)
sudo certbot --nginx -d ba.christoferperez.com
```

### 5b — Script webhook Python

```bash
nano /home/ba/ba/scripts/bot_webhook.py
```

```python
#!/usr/bin/env python3
# Bot Telegram webhook — Business Ascension™
import os, json
from http.server import HTTPServer, BaseHTTPRequestHandler
import subprocess

TOKEN = os.environ["TELEGRAM_TOKEN"]
CHAT_ID = os.environ["TELEGRAM_CHAT_ID"]

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["Content-Length"])
        body = json.loads(self.rfile.read(length))
        self.send_response(200)
        self.end_headers()

        msg = body.get("message", {})
        text = msg.get("text", "")
        if text:
            self.handle_message(text)

    def handle_message(self, text):
        import urllib.request
        # Appel Claude CLI avec contexte BA
        result = subprocess.run(
            ["claude", "-p", text],
            capture_output=True, text=True, timeout=60
        )
        response = result.stdout.strip() or "Pas de réponse."
        # Envoyer via Telegram API
        url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
        data = json.dumps({"chat_id": CHAT_ID, "text": response[:4096]}).encode("utf-8")
        req = urllib.request.Request(url, data=data,
            headers={"Content-Type": "application/json; charset=utf-8"})
        urllib.request.urlopen(req)

    def log_message(self, *args): pass

if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8443), WebhookHandler).serve_forever()
```

### 5c — Enregistrer le webhook Telegram

```bash
# Remplacer YOUR_DOMAIN par ton domaine ou IP
curl -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://YOUR_DOMAIN/webhook"}'

# Vérifier
curl "https://api.telegram.org/bot${TELEGRAM_TOKEN}/getWebhookInfo"
```

### 5d — Service systemd pour le bot

```bash
sudo nano /etc/systemd/system/ba-bot.service
```

```ini
[Unit]
Description=Business Ascension Telegram Bot
After=network.target

[Service]
User=ba
WorkingDirectory=/home/ba/ba
EnvironmentFile=/home/ba/.env
ExecStart=/usr/bin/python3 scripts/bot_webhook.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable ba-bot
sudo systemctl start ba-bot
sudo systemctl status ba-bot
```

---

## ÉTAPE 6 — Cron jobs Linux (~15 min)

```bash
crontab -e
```

Ajouter :

```cron
# Mercredi 08h00 — Agent Analytics
0 8 * * 3 cd /home/ba/ba && cat agents/agent-analytics-prompt.md | claude -p >> logs/analytics-$(date +\%Y-\%m-\%d).log 2>&1

# Vendredi 15h00 — Agent Check-in clients
0 15 * * 5 cd /home/ba/ba && cat agents/agent-checkin-prompt.md | claude -p >> logs/checkin-$(date +\%Y-\%m-\%d).log 2>&1

# Dimanche 18h00 — Agent Veille marché
0 18 * * 0 cd /home/ba/ba && python3 scripts/search_veille.py | claude -p "$(cat agents/agent-veille-prompt.md)" >> logs/veille-$(date +\%Y-\%m-\%d).log 2>&1
```

Vérifier :
```bash
crontab -l
```

---

## ÉTAPE 7 — Tests finaux (~30 min)

| Test | Commande | Attendu |
|---|---|---|
| Claude CLI | `echo "Salut" \| claude -p` | Réponse en quelques secondes |
| Bot Telegram | Envoyer `/aide` dans Telegram | Liste des commandes |
| Bot — question libre | "Génère un DM LinkedIn" | Réponse en voix Chris |
| Cron — test manuel | Exécuter le cron veille à la main | Log créé dans `/logs/` |
| Supabase | `python3 -c "from supabase import create_client; print('OK')"` | OK |
| Encodage | Envoyer "Génère un post avec des accents" | Réponse sans caractères corrompus |

---

## AVANTAGES VPS VS PC LOCAL

| Critère | PC local | VPS Hetzner |
|---|---|---|
| Uptime | Dépend que le PC soit allumé | 99,9% — 24h/24 |
| Telegram | Polling (délai) | Webhook (instantané) |
| Crons | Task Scheduler Windows (admin requis) | Cron Linux natif (simple) |
| Encodage | Problèmes Windows-1252 | Linux UTF-8 par défaut |
| IP fixe | Non | Oui (webhook stable) |
| Coût | 0€ (mais contraintes) | ~4,50€/mois |
| Scalabilité | Limité | Upgrade facile (CX31, CX41) |

---

## APRÈS LA MIGRATION

- [ ] Désactiver le bot PowerShell local (ne pas laisser les deux tourner en parallèle)
- [ ] Mettre à jour MEMORY.md avec l'IP du VPS et la date de migration
- [ ] Vérifier que les agents reçoivent bien les rapports via Telegram pendant 1 semaine
- [ ] Connecter les agents au Supabase (update des scripts pour lire/écrire en base)

---

*Business Ascension™ — Checklist VPS Hetzner — Mai 2026*
*Migration prévue : 28/05/2026 à 10h*
