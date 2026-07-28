# Incident Report: [Short Title]

**Scenario #:** [19]
**Date:** [28/07/2026]
**Environment:** [Azure Key Vault]
**Severity (self-assessed):** [High]
**Time to resolution:** [15 minutes]

---

## 1. Ticket

TICKET#019 — Priority: High
Reported by: Dev Team
Time: 14:00

"Hi, our application is failing to start — it's throwing an access denied error when trying to read its connection string from Key Vault. The Key Vault exists and the secret is definitely in there. We haven't changed anything. Can you investigate?"

## 2. Initial Triage

Confirmed the key vault exists

az role assignment list \
  --scope $(az keyvault show --name kv-incidentsim-cj --query id -o tsv) \
  --output table

## 3. Investigation

Unable to confirm if the secret exists, due to missing permissions

## 4. Root Cause

The role assignment was missing. The key vault was fine, and the secret was stored, but the missing assignment means the app (myself, in this simulation) is unable to read the secret

## 5. Resolution

az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee <identity-id> \
  --scope $(az keyvault show --name kv-incidentsim-cj --query id -o tsv)

In a real environment the flow would be:

App has a Managed Identity (not a user) assigned the Key Vault role
Managed Identity gets removed/changed → app loses access → throws access denied on startup
Fix: identify the app's Managed Identity → re-assign the correct Key Vault role

## 6. Verification

How you confirmed the fix worked (e.g. curl output, screenshot of the
app responding, metrics returning to normal).

## 7. What Was Actually Changed (Reveal)

The fault removed the Key Vault Secrets Officer role assignment from your user identity, simulating an application's Managed Identity losing access to Key Vault — which would cause exactly the "access denied reading secret" error the ticket described.

## 8. Learning Notes

- **What went well:** Correctly identified the issue was RBAC/access 
  policy rather than the Key Vault or secret itself — the ticket 
  confirmed the secret existed, so the investigation focused on 
  who had access to read it.

- **What took longer than expected:** Initial confusion about how to 
  investigate when you don't have access yourself. Key insight — as a 
  cloud engineer you typically have Owner/Contributor on the subscription 
  which lets you manage RBAC even without secret read access. You fix 
  the app's identity access, not necessarily read the secret yourself.

- **Hints used:** N/A

- **What I'd check first if this happened again:** Key Vault → Access 
  Control (IAM) → Role assignments — check if the app's Managed Identity 
  has the correct role (Key Vault Secrets User for read-only). If missing, 
  re-assign.

- **Prevention:** Azure Monitor alert on Key Vault role assignment changes 
  via Activity Log. Apps should use `Key Vault Secrets User` (read-only) 
  not `Key Vault Secrets Officer` — principle of least privilege. 
  Azure Policy can enforce Key Vault access policies. Regular access 
  reviews to confirm Managed Identity assignments are correct.

---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
