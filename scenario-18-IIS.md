# Incident Report: [ISS Service]

**Scenario #:** [18]
**Date:** [27/07/2026]
**Environment:** [WindowsVM]
**Severity (self-assessed):** [High]
**Time to resolution:** [30minutes]

---

## 1. Ticket

TICKET#018 — Priority: High
Reported by: Rachel (Support)
Time: 11:30

"Hi, App 2 on the Windows server is completely unreachable — customers are getting nothing. The server itself looks healthy in the portal. This app runs on IIS. Can you investigate and get it back up?"

## 2. Initial Triage

Initially confirmed VM was running and healthy. This pointed to the service or a network issue

## 3. Investigation

Step-by-step account of your investigation — commands run, tools used,
what you observed at each step. Include relevant CLI output or screenshots.

```
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Get-Service -Name W3SVC | Select-Object Name, Status, StartType"
```

## 4. Root Cause

The above command shows that the service was not running and set to disabled. This means the service will not start when the VM starts and is currently not running.

## 5. Resolution

Steps taken to fix it. Include commands/config changes.

Changed the startup type to automatic so when the VM starts, the service starts and started the service again

```
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Set-Service -Name W3SVC -StartupType Automatic; Start-Service -Name W3SVC"
```

## 6. Verification

confirmed original CLI command to show the service as running and automatic
curl http://137.117.247.55 confirmed the status as OK

## 7. What Was Actually Changed (Reveal)

The fault installed IIS, created a simple status page, then stopped the W3SVC service and set it to Disabled — same pattern as scenario 13 (TermService) but for IIS instead of RDP.

## 8. Learning Notes

- What went well

The troubleshooting path was the correct one to use.
The diagnostic flow is identical to the nginx/TermService scenarios — service stopped, start it, verify. The only differences are the service name (W3SVC vs nginx vs TermService) and the tool (PowerShell Get-Service vs systemctl). This is worth noting — the pattern transfers across services and OS types.

- What took longer than expected, and why

Writing out the CLI commands - this is to build my muscle memory rather than relying on AI to write them quickly for effeciency

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

AI prompts to check CLI commands 

- What you'd check first if this happened again

I would use the same process again to check the service

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)
Azure Monitor alert on W3SVC service state change (Event ID 7036). Change control over service configuration changes. IIS health probe via Application Gateway or Azure Monitor availability test would detect the outage within minutes.


---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
