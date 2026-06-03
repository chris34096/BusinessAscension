# setup-agents-user-account.ps1
# Re-enregistre les 10 agents BA sous le compte UTILISATEUR (au lieu de SYSTEM).
# Raison : claude CLI + auth Claude vivent dans le profil utilisateur ;
# SYSTEM n'y a pas acces -> les agents echouent en planifie. Ce fix corrige l'autonomie.
#
# LogonType Interactive = tourne dans ta session quand tu es connecte (PC allume).
#
# USAGE : clic droit > Executer avec PowerShell (auto-elevation incluse).

# --- Auto-elevation admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Elevation admin necessaire - relance..."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$user = "$env:USERDOMAIN\$env:USERNAME"
Write-Host "Compte cible : $user"

$tasks = @(
    'BA_Agent_Analytics','BA_Agent_CheckIn','BA_Agent_Contenu','BA_Agent_KPI',
    'BA_Agent_Orchestrateur','BA_Agent_Prospection','BA_Agent_Setting','BA_Agent_Veille',
    'BA_Agent_LeadIntelligence','BA_Agent_ContentEngine'
)

$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Highest

foreach ($t in $tasks) {
    try {
        $existing = Get-ScheduledTask -TaskName $t -ErrorAction Stop
        Set-ScheduledTask -TaskName $t -Principal $principal -ErrorAction Stop | Out-Null
        Write-Host "OK - $t -> $user"
    } catch {
        Write-Host "SKIP - $t (introuvable ou erreur : $($_.Exception.Message))"
    }
}

Write-Host ""
Write-Host "=== Termine. Les agents tournent maintenant sous ton compte. ==="
Write-Host "Ils s'executeront a leur horaire quand ta session est ouverte."
Start-Sleep -Seconds 3
