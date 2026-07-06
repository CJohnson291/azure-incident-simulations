# Incident Report: [RDP Firewall]

**Scenario #:** [14]
**Date:** [06/07/2026]
**Environment:** [Windows Server 2022 VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [30 minutes]

---

## 1. Ticket

TICKET#014 — Priority: High
Reported by: Alex (IT Manager)
Time: 14:00
"Hi again — same engineer as yesterday still can't RDP into the Windows VM. We checked and the RDP service is definitely running this time. VM is healthy, NSG rules look fine. Getting a different error than yesterday though. Can you take a look?"

## 2. Initial Triage

RDP to VM to check error code 

Error code: 0x204 connection refused
## 3. Investigation

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Get-Service -Name TermService | Select-Object Name, Status, StartType"

Confirmed RDP service is running

Checked IP range

Checked firewall settings

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Get-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' | Select-Object DisplayName, Enabled, Direction"



## 4. Root Cause

RDP disabled in host firewall at the OS level, preventing RDP access

## 5. Resolution

Changed RDP to enabled in firewall

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -Enabled True"

## 6. Verification

Used Windows App to RDP onto VM to confirm

## 7. What Was Actually Changed (Reveal)

The fault disabled the Windows Firewall rule for RDP:

```powershell
Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -Enabled False
```

This is a different layer from scenario 13 — the RDP service (TermService) was running fine, port 3389 was listening, and the Azure NSG was correctly configured. The block was at the Windows host firewall level, which sits between the NSG and the service itself.

Why 0x204 again: both scenarios produce the same error code because in both cases nothing responds on port 3389 — scenario 13 because the service wasn't running, scenario 14 because the firewall was dropping the packets before they reached the service.

The diagnostic difference:

Scenario 13: Get-Service TermService → stopped
Scenario 14: Get-Service TermService → running, netstat shows 3389 listening, but still 0x204 → host firewall

## 8. Learning Notes

- What went well

The logical process of what to check and the order is making a lot more sense and I can visualise the flow a lot better using the simulations

- What took longer than expected, and why

I came to a halt when I realised the NSG, port, IP range and service running was all correct. I was looking around the Azure portal to try and identify the cause. As I had not RDP into this VM before, I was not able to see its firewall so the only way would be via the command line

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

Hint provided to check Windows host firewall after exhausting Azure-layer checks"

- What you'd check first if this happened again

I would have progressed to checking the firewall rules sooner, now that I have that little bit of experience

RDP diagnostic flow — now you have both scenarios:

Check Azure NSG — timeout vs refused
Check TermService — Get-Service
Check port listening — netstat -an | findstr 3389
Check Windows Firewall — Get-NetFirewallRule

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Change control via CAB for any firewall rule modifications. Azure Monitor alert on Windows Firewall rule changes via Windows Event Log (Event ID 2004/2006 for rule modifications). Microsoft Defender for Cloud can also flag unexpected firewall rule changes as security alerts.
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
