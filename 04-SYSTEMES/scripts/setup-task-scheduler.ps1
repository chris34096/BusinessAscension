# setup-task-scheduler.ps1
# Setup unique — enregistre tous les agents BA™ dans Windows Task Scheduler
# v2.0 — Orchestrateur ajouté (06h30 quotidien, avant tous les autres)
# Exécuter une seule fois en tant qu'Administrateur

$BA = "E:\Document\VS CODE\Marketing\Business Ascension" + [char]0x2122
$ScriptsDir = "$BA\04-SYSTEMES\scripts"
$LogDir     = "$BA\04-SYSTEMES\agents\outputs\logs"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# --- AGENT ORCHESTRATEUR : lun-ven à 06h30 (cerveau central — avant tous les autres) ---
$ActionOrch = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-orchestrateur.ps1`""

$TriggerOrch = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday `
    -At "06:30"

$SettingsOrch = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Orchestrateur" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionOrch `
    -Trigger $TriggerOrch `
    -Settings $SettingsOrch `
    -Description "Business Ascension - Orchestrateur cerveau central (lun-ven 06:30)" `
    -Force

Write-Host "OK BA_Agent_Orchestrateur enregistre (lun-ven 06:30)"

# --- AGENT KPI : lundi à 7h00 ---
$ActionKPI = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-kpi.ps1`""

$TriggerKPI = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday `
    -At "07:00"

$SettingsKPI = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_KPI" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionKPI `
    -Trigger $TriggerKPI `
    -Settings $SettingsKPI `
    -Description "Business Ascension - Agent KPI hebdomadaire (lundi 07:00)" `
    -Force

Write-Host "OK BA_Agent_KPI enregistre (lundi 07:00)"

# --- AGENT PROSPECTION : lundi-vendredi à 8h00 ---
$ActionProspection = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-prospection.ps1`""

$TriggerProspection = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday `
    -At "08:00"

$SettingsProspection = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Prospection" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionProspection `
    -Trigger $TriggerProspection `
    -Settings $SettingsProspection `
    -Description "Business Ascension - Agent Prospection quotidien (8h00, lun-ven)" `
    -Force

Write-Host "OK BA_Agent_Prospection enregistre (lun-ven 08:00)"

# --- AGENT CONTENU : lundi, mercredi, vendredi à 9h00 ---
$ActionContenu = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-contenu.ps1`""

$TriggerContenu = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday,Wednesday,Friday `
    -At "09:00"

$SettingsContenu = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Contenu" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionContenu `
    -Trigger $TriggerContenu `
    -Settings $SettingsContenu `
    -Description "Business Ascension - Agent Contenu (9h00, lun/mer/ven)" `
    -Force

Write-Host "OK BA_Agent_Contenu enregistre (lun/mer/ven 09:00)"

# --- AGENT SETTING : lundi-vendredi à 18h00 ---
$ActionSetting = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-setting.ps1`""

$TriggerSetting = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday `
    -At "18:00"

$SettingsSetting = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Setting" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionSetting `
    -Trigger $TriggerSetting `
    -Settings $SettingsSetting `
    -Description "Business Ascension - Agent Setting quotidien (18h00, lun-ven)" `
    -Force

Write-Host "OK BA_Agent_Setting enregistre (lun-ven 18:00)"

# --- AGENT CHECK-IN : vendredi à 15h00 ---
$ActionCheckin = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-checkin.ps1`""

$TriggerCheckin = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Friday `
    -At "15:00"

$SettingsCheckin = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_CheckIn" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionCheckin `
    -Trigger $TriggerCheckin `
    -Settings $SettingsCheckin `
    -Description "Business Ascension - Agent Check-in clients actifs (vendredi 15:00)" `
    -Force

Write-Host "OK BA_Agent_CheckIn enregistre (vendredi 15:00)"

# --- AGENT ANALYTICS : mercredi à 08h00 ---
$ActionAnalytics = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-analytics.ps1`""

$TriggerAnalytics = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Wednesday `
    -At "08:00"

$SettingsAnalytics = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Analytics" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionAnalytics `
    -Trigger $TriggerAnalytics `
    -Settings $SettingsAnalytics `
    -Description "Business Ascension - Agent Analytics hebdomadaire (mercredi 08:00)" `
    -Force

Write-Host "OK BA_Agent_Analytics enregistre (mercredi 08:00)"

# --- AGENT VEILLE : dimanche à 18h00 ---
$ActionVeille = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -WindowStyle Hidden -File `"$ScriptsDir\run-agent-veille.ps1`""

$TriggerVeille = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek Sunday `
    -At "18:00"

$SettingsVeille = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 20) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask `
    -TaskName "BA_Agent_Veille" `
    -TaskPath "\BusinessAscension\" `
    -Action $ActionVeille `
    -Trigger $TriggerVeille `
    -Settings $SettingsVeille `
    -Description "Business Ascension - Agent Veille marché hebdomadaire (dimanche 18:00)" `
    -Force

Write-Host "OK BA_Agent_Veille enregistre (dimanche 18:00)"

# Résumé final
Write-Host ""
Write-Host "=== AGENTS BUSINESS ASCENSION configurés (v2.0) ==="
Write-Host "BA_Agent_Orchestrateur -> lun-ven 06:30 [CERVEAU CENTRAL - NOUVEAU]"
Write-Host "BA_Agent_KPI           -> lundi 07:00"
Write-Host "BA_Agent_Prospection   -> lun-ven 08:00"
Write-Host "BA_Agent_Contenu       -> lun/mer/ven 09:00"
Write-Host "BA_Agent_Setting       -> lun-ven 18:00"
Write-Host "BA_Agent_Analytics     -> mercredi 08:00"
Write-Host "BA_Agent_CheckIn       -> vendredi 15:00"
Write-Host "BA_Agent_Veille        -> dimanche 18:00"
Write-Host ""
Write-Host "Fichiers d'état partagés : 04-SYSTEMES\agents\state\"
Write-Host "  - daily-brief.md       (écrit par Orchestrateur, lu par tous)"
Write-Host "  - content-performance  (mis à jour par Contenu + Analytics)"
Write-Host "  - prospect-tracker     (mis à jour par Prospection + Setting)"
Write-Host "  - client-insights      (mis à jour par Check-in + Objections)"
Write-Host ""
Write-Host "Vérifier dans : Planificateur de taches > \BusinessAscension\"
Write-Host "Outputs dans  : 04-SYSTEMES\agents\outputs\"
