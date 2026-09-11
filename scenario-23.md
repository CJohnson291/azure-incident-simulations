# Incident Report: [Short Title]

**Scenario #:** [23]
**Date:** [11/09/2025]
**Environment:** [Windows Server 2022]
**Severity (self-assessed):** [Medium]
**Time to resolution:** [20 minutes]

---

## 1. Ticket

TICKET#023 — Priority: High
Reported by: Support Desk**
Time: 10:00**

"Morning — The print service on the Windows server has stopped — users can't print. The app is called 'Print Spooler'. Can you find the service and restart it?"

## 2. Initial Triage

Confirmed VM is running, confirming the report is accurate

## 3. Investigation

Ran PowerShell command to check service status and startup type. Confirmed service was Stopped with StartupType set to Disabled — meaning it couldn't be started until re-enabled

```
Get-Service -Name Spooler | Select-Object Name, Status, StartType
```

## 4. Root Cause

Service was not running, but also not enabled

## 5. Resolution

Steps taken to fix it. 

Enabling the service, then, starting the service

```
Set-Service -Name Spooler -StartupType Automatic
Start-Service -Name Spooler
```

## 6. Verification

Confirmed by running command below - showed service as running

Get-Service | Where DisplayName -match "Spooler"

## 7. What Was Actually Changed (Reveal)

The fault stopped the Print Spooler service (Spooler) and set it to Disabled, simulating an application service being down. The ticket gave you the display name ("Print Spooler") not the service name (Spooler) — the key skill was using Get-Service with a wildcard or browsing the full service list to match display name to service name, then checking StartType before attempting to start.

## 8. Learning Notes

- **What went well:** Correctly identified the service quickly using 
  `Get-Service` — matching the display name "Print Spooler" to the 
  service name `Spooler`. Recognised that StartType Disabled required 
  re-enabling before starting.

- **What took longer than expected:** Initial attempt to start the 
  service failed with an error — needed to set StartupType to Automatic 
  first. Good lesson: always check StartType before attempting Start-Service.

- **Hints used:** Guidance on checking StartType and the correct order 
  of Set-Service then Start-Service.

- **What I'd check first if this happened again:** `Get-Service "name*"` 
  to find the service, then check StartType immediately before attempting 
  to start. If Disabled — re-enable first.

- **Prevention:** Azure Monitor alert on service state changes (Event ID 
  7036). Change control over service configuration changes. For critical 
  services like Print Spooler, a monitoring tool checking service status 
  would catch this within minutes.


Key notes

Get-Service "name*" — wildcard search when you only know the app name
Get-Service | Sort DisplayName — browse all services by display name when searching
Always check StartType before Start-Service — Disabled services need re-enabling first
Display name ≠ service name on Windows — Print Spooler is Spooler, World Wide Web Publishing Service is W3SVC, Remote Desktop Services is TermService
---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
