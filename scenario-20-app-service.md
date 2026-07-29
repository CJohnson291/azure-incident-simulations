# Incident Report: [Short Title]

**Scenario #:** [20]
**Date:** [29/07/2026]
**Environment:** [App Service]
**Severity (self-assessed):** [High]
**Time to resolution:** [15 minutes]

---

## 1. Ticket

TICKET#020 — Priority: High
Reported by: Dev Team
Time: 10:15

"Hi, our application deployed to Azure App Service has suddenly stopped connecting to the database. It was working fine yesterday, nothing has changed in the code. We're seeing authentication errors in the logs. The app itself is running but all database operations are failing. Can you investigate?"

## 2. Initial Triage

App running and DB confirmed to be ok, points to a connection between the two services

## 3. Investigation

Navigated to App Service → Configuration → Application settings in Azure Portal. Reviewed the DATABASE_URL environment variable which showed WRONG-PASSWORD as the password value

## 4. Root Cause

Password set in the app setting varibles was incorrect (WRONG-PASSWORD)

## 5. Resolution

Amended password (correct-password) then confirmed the change via command below

```
az webapp config appsettings list \
--name webapp-incidentsim-cj \
--resource-group rg-tfstate-incidentsim \
--query "[?name=='DATABASE_URL']" \
--output table
```

## 6. Verification

How you confirmed the fix worked (e.g. curl output, screenshot of the
app responding, metrics returning to normal).

Command above confirmed the password change had taken place - the team would then need to confirm the app is able to communicate to the DB without erroring

## 7. What Was Actually Changed (Reveal)

The fault changed the DATABASE_URL app setting from correct-password to WRONG-PASSWORD, simulating a misconfigured connection string — a common cause of "app is running but can't connect to the database" errors.

## 8. Learning Notes

- **What went well:** Correctly identified the connection layer as the 
  issue — app running but DB failing points to configuration rather than 
  the app or DB themselves. Found the misconfigured setting quickly in 
  the portal.

- **What took longer than expected:** N/A — straightforward once the 
  investigation was focused on app settings.

- **Hints used:** None — located the issue independently in the portal.

- **What I'd check first if this happened again:** App Service → 
  Configuration → Application settings immediately for any "app running 
  but dependency failing" ticket. Authentication errors in logs almost 
  always point to credentials/connection string rather than network or 
  service issues.

- **Prevention:** Use Key Vault references instead of plain text secrets 
  in app settings — `@Microsoft.KeyVault(SecretUri=...)` means the actual 
  secret never lives in App Service config. Azure Monitor alert on App 
  Service configuration changes via Activity Log. Change control over 
  deployment pipelines that push app settings — a misconfigured pipeline 
  variable is the most common real-world cause of this type of fault.

---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
