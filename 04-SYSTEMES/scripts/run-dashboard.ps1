# run-dashboard.ps1
# Business Ascension™ — Dashboard Central
# Génère un dashboard HTML à partir des fichiers markdown
# Usage : exécuter manuellement ou via Telegram /dashboard

$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = "E:\Document\VS CODE\Marketing\Business Ascension" + [char]0x2122
$Date = Get-Date -Format "yyyy-MM-dd"
$DateFR = (Get-Date).ToString("dddd d MMMM yyyy", [System.Globalization.CultureInfo]::GetCultureInfo("fr-FR"))
$WeekNumber = Get-Date -UFormat "%V"
$OutputDir = "$ProjectRoot\04-SYSTEMES\agents\outputs"
$DashboardPath = "$ProjectRoot\04-SYSTEMES\dashboard.html"

Write-Host "[$Date] Génération du Dashboard BA™..."

# ─────────────────────────────────────────
# LECTURE DES FICHIERS
# ─────────────────────────────────────────

function Read-File($path) {
    if (Test-Path $path) { return Get-Content $path -Raw -Encoding UTF8 }
    return ""
}

$PipelineRaw = Read-File "$ProjectRoot\02-SALES\pipeline-suivi.md"
$OKRsRaw     = Read-File "$ProjectRoot\05-FINANCE\okrs.md"
$KPIsRaw     = Read-File "$ProjectRoot\05-FINANCE\kpis-dashboard.md"

# ─────────────────────────────────────────
# EXTRACTION — PIPELINE
# ─────────────────────────────────────────

function Count-PipelineStatus($raw, $status) {
    $count = 0
    foreach ($line in $raw -split "`n") {
        if ($line -match '\|' -and $line -notmatch '---' -and $line -notmatch 'Statut' -and $line -match $status) { $count++ }
    }
    return $count
}

$pipe_entrant = Count-PipelineStatus $PipelineRaw "ENTRANT"
$pipe_booke   = Count-PipelineStatus $PipelineRaw "AUDIT BOOK"
$pipe_reflex  = Count-PipelineStatus $PipelineRaw "R.FLEXION"
$pipe_relance = Count-PipelineStatus $PipelineRaw "RELANCE"
$pipe_signe   = Count-PipelineStatus $PipelineRaw "SIGN"
$pipe_archive = Count-PipelineStatus $PipelineRaw "ARCHIV"
$pipe_total   = $pipe_entrant + $pipe_booke + $pipe_reflex + $pipe_relance + $pipe_signe + $pipe_archive

# ─────────────────────────────────────────
# EXTRACTION — DERNIERS OUTPUTS AGENTS
# ─────────────────────────────────────────

function Get-LastOutput($prefix) {
    if (-not (Test-Path $OutputDir)) { return @{ date = "Jamais"; preview = "Aucun rapport généré" } }
    $files = Get-ChildItem "$OutputDir\$prefix*.md" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    if ($files.Count -eq 0) { return @{ date = "Jamais"; preview = "Aucun rapport généré" } }
    $latest = $files[0]
    $preview = (Get-Content $latest.FullName -TotalCount 15 -Encoding UTF8 | Out-String).Trim()
    $preview = $preview -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
    if ($preview.Length -gt 600) { $preview = $preview.Substring(0, 597) + "..." }
    return @{
        date    = $latest.LastWriteTime.ToString("dd/MM HH:mm")
        preview = $preview
    }
}

$out_kpi         = Get-LastOutput "kpi-"
$out_prospection = Get-LastOutput "prospection-"
$out_contenu     = Get-LastOutput "contenu-"
$out_setting     = Get-LastOutput "setting-"
$out_vsl         = Get-LastOutput "vsl-"
$out_checkin     = Get-LastOutput "checkin-"

# ─────────────────────────────────────────
# STATUT AGENTS (Task Scheduler)
# ─────────────────────────────────────────

function Get-TaskInfo($taskName) {
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        $info = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction Stop
        $lastRun = if ($info.LastRunTime -and $info.LastRunTime -gt [DateTime]"2000-01-01") {
            $info.LastRunTime.ToString("dd/MM HH:mm")
        } else { "Jamais" }
        $nextRun = if ($info.NextRunTime -and $info.NextRunTime -gt [DateTime]::Now) {
            $info.NextRunTime.ToString("dd/MM HH:mm")
        } else { "—" }
        return @{ state = $task.State.ToString(); lastRun = $lastRun; nextRun = $nextRun }
    } catch {
        return @{ state = "Inconnu"; lastRun = "—"; nextRun = "—" }
    }
}

function State-Badge($state) {
    switch ($state) {
        "Ready"    { return '<span class="badge badge-green">Prêt</span>' }
        "Running"  { return '<span class="badge badge-blue">En cours</span>' }
        "Disabled" { return '<span class="badge badge-red">Désactivé</span>' }
        default    { return '<span class="badge badge-gray">—</span>' }
    }
}

$st_kpi         = Get-TaskInfo "BA_Agent_KPI"
$st_prospection = Get-TaskInfo "BA_Agent_Prospection"
$st_contenu     = Get-TaskInfo "BA_Agent_Contenu"
$st_setting     = Get-TaskInfo "BA_Agent_Setting"
$st_checkin     = Get-TaskInfo "BA_Agent_CheckIn"
$st_analytics   = Get-TaskInfo "BA_Agent_Analytics"

$okr_o2_pct = if ($pipe_signe -ge 3) { 100 } else { [Math]::Round($pipe_signe / 3 * 100) }

# ─────────────────────────────────────────
# GÉNÉRATION HTML
# ─────────────────────────────────────────

$html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Business Ascension™ — Dashboard</title>
<style>
:root {
  --bg:#0c0c14;--surface:#13131e;--surface2:#1a1a28;--border:#252535;
  --accent:#e8b84b;--accent-dim:rgba(232,184,75,0.12);
  --blue:#4f8ef7;--blue-dim:rgba(79,142,247,0.12);
  --green:#10b981;--green-dim:rgba(16,185,129,0.12);
  --red:#f43f5e;--red-dim:rgba(244,63,94,0.12);
  --amber:#f59e0b;--amber-dim:rgba(245,158,11,0.12);
  --text:#e2e8f0;--muted:#64748b;
  --font:-apple-system,BlinkMacSystemFont,'Segoe UI',system-ui,sans-serif;
  --mono:'Courier New',monospace;
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--text);font-family:var(--font);font-size:14px;line-height:1.5}
.header{background:var(--surface);border-bottom:1px solid var(--border);padding:14px 28px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:100}
.logo{font-size:17px;font-weight:700;letter-spacing:-.5px}.logo span{color:var(--accent)}
.meta{font-size:12px;color:var(--muted);text-align:right}.meta strong{color:var(--text);display:block}
.main{padding:20px 28px;max-width:1600px;margin:0 auto}
.sec{font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:1.5px;color:var(--muted);margin:24px 0 12px;display:flex;align-items:center;gap:8px}
.sec::after{content:'';flex:1;height:1px;background:var(--border)}
.g4{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}
.g3{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}
.g2{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}
.card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:16px}
.card:hover{border-color:rgba(232,184,75,.4)}
.ca{border-left:3px solid var(--accent)}.cb{border-left:3px solid var(--blue)}.cg{border-left:3px solid var(--green)}.cr{border-left:3px solid var(--red)}
.lbl{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.8px;margin-bottom:6px}
.val{font-size:32px;font-weight:700;line-height:1;color:var(--accent);margin-bottom:4px}
.val.b{color:var(--blue)}.val.g{color:var(--green)}.val.r{color:var(--red)}
.sub{font-size:11px;color:var(--muted)}
.pipe{display:flex;gap:8px}
.ps{flex:1;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:14px 8px;text-align:center;transition:all .2s}
.ps:hover{border-color:var(--accent);transform:translateY(-2px)}
.ps-lbl{font-size:10px;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);margin-bottom:8px}
.ps-n{font-size:28px;font-weight:700;line-height:1;margin-bottom:4px}
.ps-s{font-size:10px;color:var(--muted)}
.s1 .ps-n{color:#94a3b8}.s2 .ps-n{color:var(--blue)}.s3 .ps-n{color:var(--amber)}.s4 .ps-n{color:#f97316}.s5 .ps-n{color:var(--green)}.s6 .ps-n{color:var(--muted)}
.okr{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:16px}
.okr-t{font-size:13px;font-weight:600;margin-bottom:12px;line-height:1.4}
.okr-t em{font-size:10px;background:var(--accent-dim);color:var(--accent);padding:2px 6px;border-radius:4px;font-style:normal;font-weight:500;margin-right:6px}
.kr{margin-bottom:10px}
.kr-h{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
.kr-l{font-size:11px;color:var(--muted)}.kr-v{font-size:11px;color:var(--text);font-weight:500}
.bar{height:5px;background:var(--border);border-radius:3px;overflow:hidden}
.fill{height:100%;border-radius:3px;background:linear-gradient(90deg,var(--accent),var(--blue));transition:width .5s}
.arow{display:flex;align-items:center;padding:10px 0;border-bottom:1px solid var(--border);gap:12px}
.arow:last-child{border-bottom:none}
.aic{width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0}
.ap{background:var(--blue-dim)}.as{background:var(--amber-dim)}.ac{background:var(--green-dim)}.ak{background:var(--accent-dim)}.av{background:var(--red-dim)}
.ainfo{flex:1;min-width:0}
.aname{font-size:13px;font-weight:600}.ameta{font-size:11px;color:var(--muted)}
.atimes{text-align:right;font-size:11px}
.atimes .ll{color:var(--muted)}.atimes .nn{color:var(--blue);font-weight:500}
.badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.5px}
.badge-green{background:var(--green-dim);color:var(--green)}.badge-blue{background:var(--blue-dim);color:var(--blue)}.badge-red{background:var(--red-dim);color:var(--red)}.badge-gray{background:var(--border);color:var(--muted)}
.out{background:var(--surface);border:1px solid var(--border);border-radius:10px;overflow:hidden}
.out-h{padding:11px 14px;background:var(--surface2);border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center}
.out-t{font-size:13px;font-weight:600}.out-d{font-size:11px;color:var(--muted)}
.out-p{padding:12px 14px;font-family:var(--mono);font-size:11px;line-height:1.6;color:#94a3b8;white-space:pre-wrap;max-height:200px;overflow:hidden;position:relative}
.out-p::after{content:'';position:absolute;bottom:0;left:0;right:0;height:50px;background:linear-gradient(transparent,var(--surface))}
.footer{margin-top:36px;padding:16px 28px;border-top:1px solid var(--border);display:flex;justify-content:space-between;font-size:11px;color:var(--muted)}
@media(max-width:1100px){.g4{grid-template-columns:repeat(2,1fr)}.pipe{flex-wrap:wrap}}
@media(max-width:768px){.main{padding:12px}.g4,.g3,.g2{grid-template-columns:1fr}}
</style>
</head>
<body>
<div class="header">
  <div class="logo">Business <span>Ascension™</span></div>
  <div class="meta"><strong>Semaine $WeekNumber</strong>$DateFR</div>
</div>
<div class="main">

<div class="sec">Vue d'ensemble</div>
<div class="g4">
  <div class="card cg"><div class="lbl">Clients IAP actifs</div><div class="val g">$pipe_signe</div><div class="sub">Inner Architecture Program™</div></div>
  <div class="card cb"><div class="lbl">Pipeline total</div><div class="val b">$pipe_total</div><div class="sub">$pipe_entrant entrant · $pipe_booke audit booké</div></div>
  <div class="card ca"><div class="lbl">En réflexion + relance</div><div class="val">$($pipe_reflex + $pipe_relance)</div><div class="sub">$pipe_reflex réflexion · $pipe_relance relance</div></div>
  <div class="card cr"><div class="lbl">Archivés</div><div class="val r">$pipe_archive</div><div class="sub">Nurturing contenu</div></div>
</div>

<div class="sec">Pipeline — Funnel de conversion</div>
<div class="pipe">
  <div class="ps s1"><div class="ps-lbl">Entrant</div><div class="ps-n">$pipe_entrant</div><div class="ps-s">DM / Formulaire</div></div>
  <div class="ps s2"><div class="ps-lbl">Audit Booké</div><div class="ps-n">$pipe_booke</div><div class="ps-s">Appel planifié</div></div>
  <div class="ps s3"><div class="ps-lbl">En Réflexion</div><div class="ps-n">$pipe_reflex</div><div class="ps-s">Appel réalisé</div></div>
  <div class="ps s4"><div class="ps-lbl">Relance</div><div class="ps-n">$pipe_relance</div><div class="ps-s">Séquence active</div></div>
  <div class="ps s5"><div class="ps-lbl">Signé</div><div class="ps-n">$pipe_signe</div><div class="ps-s">Client IAP™</div></div>
  <div class="ps s6"><div class="ps-lbl">Archivé</div><div class="ps-n">$pipe_archive</div><div class="ps-s">Nurturing</div></div>
</div>

<div class="sec">OKRs — Q2 2026 (Mai → Juillet)</div>
<div class="g3">
  <div class="okr">
    <div class="okr-t"><em>O1</em>Référence évidente pour les entrepreneurs qui stagnent</div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR1 — Reels (10 semaines)</span><span class="kr-v">0 / 50</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR2 — Abonnés qualifiés</span><span class="kr-v">0 / 500</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR3 — Candidatures Audit/sem.</span><span class="kr-v">0 / 3</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
  </div>
  <div class="okr">
    <div class="okr-t"><em>O2</em>Signer et livrer les 3 premiers clients IAP</div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR1 — Clients IAP signés</span><span class="kr-v">$pipe_signe / 3</span></div><div class="bar"><div class="fill" style="width:$($okr_o2_pct)%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR2 — Témoignages écrits</span><span class="kr-v">0 / 3</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR3 — Score satisfaction</span><span class="kr-v">— / ≥8</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
  </div>
  <div class="okr">
    <div class="okr-t"><em>O3</em>Bases opérationnelles du Business Operating System</div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR1 — Documents BOS</span><span class="kr-v">8 / 8</span></div><div class="bar"><div class="fill" style="width:100%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR2 — Stack tech actif</span><span class="kr-v">En cours</span></div><div class="bar"><div class="fill" style="width:65%"></div></div></div>
    <div class="kr"><div class="kr-h"><span class="kr-l">KR3 — KPIs MAJ hebdo</span><span class="kr-v">0 / 10</span></div><div class="bar"><div class="fill" style="width:0%"></div></div></div>
  </div>
</div>

<div class="sec">Agents autonomes — Statut</div>
<div class="g2">
  <div class="card">
    <div class="arow"><div class="aic ap">📡</div><div class="ainfo"><div class="aname">Agent Prospection</div><div class="ameta">Lun-Ven 08h00 · $(State-Badge $st_prospection.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_prospection.lastRun)</div><div class="nn">Prochain : $($st_prospection.nextRun)</div></div></div>
    <div class="arow"><div class="aic as">🌙</div><div class="ainfo"><div class="aname">Agent Setting</div><div class="ameta">Lun-Ven 18h00 · $(State-Badge $st_setting.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_setting.lastRun)</div><div class="nn">Prochain : $($st_setting.nextRun)</div></div></div>
    <div class="arow"><div class="aic ac">✍️</div><div class="ainfo"><div class="aname">Agent Contenu</div><div class="ameta">Lun/Mer/Ven 09h00 · $(State-Badge $st_contenu.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_contenu.lastRun)</div><div class="nn">Prochain : $($st_contenu.nextRun)</div></div></div>
    <div class="arow"><div class="aic ak">📊</div><div class="ainfo"><div class="aname">Agent KPI</div><div class="ameta">Lundi 07h00 · $(State-Badge $st_kpi.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_kpi.lastRun)</div><div class="nn">Prochain : $($st_kpi.nextRun)</div></div></div>
  </div>
  <div class="card">
    <div class="arow"><div class="aic ap">🤝</div><div class="ainfo"><div class="aname">Agent Check-in Client</div><div class="ameta">Vendredi 15h00 · $(State-Badge $st_checkin.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_checkin.lastRun)</div><div class="nn">Prochain : $($st_checkin.nextRun)</div></div></div>
    <div class="arow"><div class="aic ac">📈</div><div class="ainfo"><div class="aname">Agent Analytics</div><div class="ameta">Mercredi 08h00 · $(State-Badge $st_analytics.state)</div></div><div class="atimes"><div class="ll">Dernier : $($st_analytics.lastRun)</div><div class="nn">Prochain : $($st_analytics.nextRun)</div></div></div>
    <div class="arow"><div class="aic av">🎬</div><div class="ainfo"><div class="aname">Agent VSL</div><div class="ameta">Manuel · /vsl dans Telegram</div></div><div class="atimes"><div class="ll">Dernier : $($out_vsl.date)</div><div class="nn" style="color:var(--muted)">À la demande</div></div></div>
    <div class="arow"><div class="aic ap">🤖</div><div class="ainfo"><div class="aname">Bot Telegram</div><div class="ameta">Permanent · Startup Windows</div></div><div class="atimes"><div class="ll" style="color:var(--green)">● Actif 24/7</div><div class="nn" style="color:var(--muted)">@BusinessAscensionbot</div></div></div>
  </div>
</div>

<div class="sec">Derniers rapports agents</div>
<div class="g3">
  <div class="out"><div class="out-h"><span class="out-t">📊 Rapport KPI</span><span class="out-d">$($out_kpi.date)</span></div><div class="out-p">$($out_kpi.preview)</div></div>
  <div class="out"><div class="out-h"><span class="out-t">📡 Rapport Prospection</span><span class="out-d">$($out_prospection.date)</span></div><div class="out-p">$($out_prospection.preview)</div></div>
  <div class="out"><div class="out-h"><span class="out-t">✍️ Rapport Contenu</span><span class="out-d">$($out_contenu.date)</span></div><div class="out-p">$($out_contenu.preview)</div></div>
</div>
<div class="g3" style="margin-top:12px">
  <div class="out"><div class="out-h"><span class="out-t">🌙 Rapport Setting</span><span class="out-d">$($out_setting.date)</span></div><div class="out-p">$($out_setting.preview)</div></div>
  <div class="out"><div class="out-h"><span class="out-t">🤝 Rapport Check-in</span><span class="out-d">$($out_checkin.date)</span></div><div class="out-p">$($out_checkin.preview)</div></div>
  <div class="out"><div class="out-h"><span class="out-t">🎬 Rapport VSL</span><span class="out-d">$($out_vsl.date)</span></div><div class="out-p">$($out_vsl.preview)</div></div>
</div>

</div>
<div class="footer">
  <span>Business Ascension™ · Dashboard généré le $DateFR</span>
  <span>Semaine $WeekNumber · Phase bêta IAP™ · 3-5 premiers clients</span>
</div>
</body></html>
"@

$html | Out-File $DashboardPath -Encoding UTF8
Write-Host "Dashboard généré : $DashboardPath"
Start-Process $DashboardPath
Write-Host "[$Date] Dashboard BA™ prêt."
