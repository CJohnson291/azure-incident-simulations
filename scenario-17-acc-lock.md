# Incident Report: Account Lockout - RDP Authentication Failure

**Scenario #:** 17
**Date:** 15/07/2026
**Environment:** Windows VM
**Severity (self-assessed):** High
**Time to resolution:** 30 minutes (theoretical)

---

## 1. Ticket

TICKET#017 — Priority: High
Reported by: helpdesk team
Time: 08:45
"Morning — we've had a report that an engineer cannot RDP into the Windows VM. 
They're getting an authentication error rather than a connection error. The VM 
is running, NSG looks fine. They're adamant they're using the correct password. 
Can you investigate?"

## 2. Initial Triage

Confirmed I could RDP onto the VM myself — rules out NSG, TermService, 
and Windows Firewall as the cause. "Authentication error, correct password" 
points directly to the account layer rather than the network or service layer.

## 3. Investigation

Checked account status:

```powershell
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "net user azureadmin"
```

Returned `Account active: No` and `Account locked out: Yes` — confirming 
the account had been locked after exceeding the failed login threshold.

Checked lockout policy:

```powershell
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "net accounts"
```

Returned lockout threshold of 3 attempts, 30 minute duration.

Checked Windows Security Event Log for lockout events:

```powershell
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Get-WinEvent -LogName Security -FilterXPath \
  '*[System[EventID=4740]]' | Select-Object TimeCreated, Message -First 5"
```

Event ID 4740 confirmed account lockout — showing timestamp and source 
of the failed attempts.

## 4. Root Cause

The `azureadmin` account was locked out after exceeding the lockout 
threshold of 3 failed login attempts. The lockout policy was set to 
30 minutes duration. The engineer's correct password was being rejected 
because the account was locked, not because the password was wrong.

## 5. Resolution

Unlocked the account via Run Command:

```powershell
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "net user azureadmin /active:yes"
```

## 6. Verification

Re-ran `net user azureadmin` — confirmed `Account active: Yes` and 
`Account locked out: No`. Engineer confirmed RDP access restored.

## 7. What Was Actually Changed (Reveal)

The fault set a lockout policy (threshold: 3 attempts, duration: 30 
minutes) and triggered multiple failed login attempts against the 
`azureadmin` account, locking it out. Note: this scenario was completed 
theoretically — the built-in administrator account on Windows Server has 
protections preventing reliable lockout simulation via Run Command. The 
diagnostic flow and resolution are accurate to a real-world incident.

## 8. Learning Notes

- **What went well:** The symptom — "authentication error, correct 
  password" — immediately distinguished this from a network or service 
  fault. Being able to RDP in myself confirmed the issue was 
  account-specific, not environmental.

- **What took longer than expected:** In a real Entra ID environment, 
  sign-in logs would surface the lockout immediately. For a local Windows 
  account on an IaaS VM there are no Entra logs — had to use Windows 
  Event Log (Event ID 4740) and `net user` via Run Command instead.

- **Hints used:** Full theoretical walkthrough — fault injection did not 
  apply reliably due to built-in administrator account protections on 
  Windows Server.

- **What I'd check first if this happened again:** `net user <username>` 
  immediately — account active/locked status is the fastest check when 
  the symptom is "authentication error with correct password."

- **Prevention:** Azure Monitor alert on Event ID 4740 (account lockout) 
  and Event ID 4625 (failed logon). Azure AD PIM for just-in-time RDP 
  access rather than permanent local accounts. MFA enforcement on RDP 
  via Azure AD joined VMs. Review lockout threshold — 3 attempts is 
  aggressive for a shared admin account, 5-10 more typical.

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*