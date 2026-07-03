# Incident Report: [RDP]

**Scenario #:** [13]
**Date:** [03/07/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [20 minutes]

---

## 1. Ticket

TICKET#013 — Priority: High

Reported by: Alex (IT Manager)**

Time: 09:00
"Morning — one of our engineers can't RDP into the Windows VM. They were connected fine yesterday, nothing has changed as far as we know. VM shows as running in the portal. Can you investigate and restore access?"

## 2. Initial Triage

Checked NSG rules, RDP Allowed from correct IP range
RDP Error code: 0x204

## 3. Investigation

Error code 0x204 means the connection was refused — the client reached the host but nothing was listening on port 3389. This points directly to the RDP service (TermService) not running rather than a network block (which would give a timeout instead).

az vm run-command invoke \
>   --resource-group rg-incidentsim-windows \
>   --name vm-win-app1 \
>   --command-id RunPowerShellScript \
>   --scripts "Get-Service -Name TermService | Select-Object Name, Status, StartType"

This showed that the RDP service had been stopped

## 4. Root Cause

Error code 0x204 and command above identified the root cause as the RDP service as stopped

## 5. Resolution

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Set-Service -Name TermService -StartupType Automatic; Start-Service -Name TermService"

## 6. Verification

Succesfully used the Windows App to RDP into the VM 

## 7. What Was Actually Changed (Reveal)

Scenario 13 — Reveal:
The fault stopped the RDP service (TermService) and set it to disabled:

powershellStop-Service -Name TermService -Force
Set-Service -Name TermService -StartupType Disabled

## 8. Learning Notes

- **What went well:** Error code interpretation was key — 0x204 
  (connection refused) immediately ruled out a network block and pointed 
  toward the service layer. Went straight to checking TermService status 
  which confirmed the root cause quickly.

- **What took longer than expected:** N/A — clean diagnosis and 
  resolution. First Windows scenario but the diagnostic flow (network 
  → service → config) translated directly from Linux experience.

- **Hints used:** Error code definition provided with assistance — 
  worth adding RDP error codes to engineer-notes.md for future reference.

- **What I'd check first if this happened again:** RDP error code first 
  — timeout = network layer (NSG, firewall), 0x204 = service not 
  listening, credentials error = authentication issue. Then 
  `Get-Service -Name TermService` to confirm service status.

- **Prevention:** Azure Monitor alert on TermService stopping. Change 
  control over service configuration changes. Windows Event Log 
  monitoring for service state changes — Event ID 7036 logs every 
  service start/stop. In production, JIT access would also reduce the 
  attack surface on port 3389.
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
