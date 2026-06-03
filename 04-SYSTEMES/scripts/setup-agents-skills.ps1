# setup-agents-skills.ps1
# Enregistre les 2 nouveaux agents (skills) dans le Task Scheduler.
# Auto-elevation : relance en admin si necessaire.
#
# USAGE : clic droit > Executer avec PowerShell  (ou : powershell -File setup-agents-skills.ps1)

# --- Auto-elevation admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevation admin necessaire - relance..."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$root = "E:\Document\VS CODE\Marketing\Business Ascension" + [char]0x2122 + "\04-SYSTEMES\scripts"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$days = @('Monday','Tuesday','Wednesday','Thursday','Friday')

# Agent Lead Intelligence - lun-ven 8h30
$a1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -WindowStyle Hidden -File `"$root\run-agent-lead-intelligence.ps1`""
$t1 = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 8:30am
Register-ScheduledTask -TaskName "BA_Agent_LeadIntelligence" -Action $a1 -Trigger $t1 -Principal $principal -Force | Out-Null
Write-Host "OK - BA_Agent_LeadIntelligence (lun-ven 8h30)"

# Agent Content Engine - lun-ven 9h00
$a2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -WindowStyle Hidden -File `"$root\run-agent-content-engine.ps1`""
$t2 = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At 9:00am
Register-ScheduledTask -TaskName "BA_Agent_ContentEngine" -Action $a2 -Trigger $t2 -Principal $principal -Force | Out-Null
Write-Host "OK - BA_Agent_ContentEngine (lun-ven 9h00)"

Write-Host ""
Write-Host "=== Les 2 nouveaux agents sont actifs. Total : 10 agents BA. ==="
Start-Sleep -Seconds 3
