# Incident Report: SSH Access Denied - nologin Shell

**Scenario #:** 10
**Date:** 01/07/2026
**Environment:** App 1 - baseline VM
**Severity (self-assessed):** Medium
**Time to resolution:** 30 minutes 

---

## 1. Ticket

TICKET#010 — Priority: Medium

Reported by: Dev team

Time: 11:20
"Hey, the app itself seems fine — customers aren't reporting issues — 
but one of our engineers says they can no longer SSH into App 1 to do 
their usual maintenance checks. They're getting kicked out immediately 
after connecting. Can you take a look? Not urgent for customers but we 
need access restored."

## 2. Initial Triage

App confirmed healthy via curl — customer-facing service unaffected. 
Focused investigation on SSH access only. Initial assumption was an NSG 
rule change blocking port 22, or an IP allowlist mismatch.

## 3. Investigation

Checked current IP and compared to NSG Allow-SSH rule — mismatch found, 
updated NSG source IP to current address.

Checked NSG association with NIC — returned empty, meaning NSG rules 
were not being applied at all. Re-associated NSG to NIC:

```bash
az network nic update \
  --resource-group rg-incidentsim \
  --name nic-incidentsim-app1 \
  --network-security-group nsg-incidentsim-app1
```

SSH still timed out after both fixes. Confirmed SSH service was running 
and healthy via Run Command:

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo systemctl status ssh"
```

SSH service active and listening on port 22. Confirmed no host firewall 
blocking — ufw inactive, iptables open. Investigated user account 
directly:

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "getent passwd azureuser"
```

Returned:

azureuser:x:1000:1000:Ubuntu:/home/azureuser:/usr/sbin/nologin

The final field confirms the login shell was set to `/usr/sbin/nologin` 
— meaning authentication would succeed but the server immediately 
rejects the session, explaining the "kicked out immediately" symptom.

## 4. Root Cause

The `azureuser` login shell was changed to `/usr/sbin/nologin`, 
preventing any interactive SSH session from being established. SSH key 
authentication succeeds but the server closes the connection immediately 
as nologin explicitly rejects interactive logins.

Note: investigation was significantly delayed by a recurring 
environmental issue where the NSG was not associated to the NIC on 
deployment — an Azure trial subscription quirk unrelated to the actual 
fault.

## 5. Resolution

Restored the login shell to `/bin/bash` via Run Command:

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo usermod -s /bin/bash azureuser && getent passwd azureuser"
```

Returned:

azureuser:x:1000:1000:Ubuntu:/home/azureuser:/bin/bash

## 6. Verification

Confirmed via `getent passwd azureuser` output showing `/bin/bash` as 
the login shell. SSH verification via terminal was not possible due to 
the persistent environmental network issue on this subscription — Run 
Command used as the verification method throughout.

## 7. What Was Actually Changed (Reveal)

The fault changed the azureuser login shell to `/usr/sbin/nologin`:

```bash
sudo usermod -s /usr/sbin/nologin azureuser
```

SSH connection authenticates successfully but the server immediately 
closes the session because nologin explicitly rejects interactive 
logins. Fix is `usermod -s /bin/bash azureuser` to restore the default 
shell.

## 8. Learning Notes

- **What went well:** Correctly identified the NSG association issue as 
  a separate environmental problem and didn't conflate it with the 
  actual fault. Methodically worked through each layer (network, 
  service, account) until the real cause was found.

- **What took longer than expected:** The NSG not being associated to 
  the NIC on deployment is a recurring issue on this Azure trial 
  subscription — added as a standard post-deploy check going forward. 
  This masked the real fault for most of the investigation.

- **Hints used:** Full walkthrough required — environmental issues 
  obscured the investigation path and the root cause was identified with 
  assistance. Key learning: "kicked out immediately" is a distinct 
  symptom from a timeout and points to the account/shell layer, not the 
  network layer.

- **What I'd check first if this happened again:** Confirm NSG is 
  associated to NIC first (post-deploy check). Then if SSH times out vs 
  kicks out immediately — timeout = network layer, immediate rejection = 
  authentication or shell layer. Run `getent passwd username` to check 
  login shell immediately.

- **Prevention:** Change control over user account modifications. Azure 
  AD PIM (Privileged Identity Management) for just-in-time SSH access 
  rather than permanent admin accounts. Azure Monitor alert on user 
  account changes via Activity Log. Regular access reviews to confirm 
  admin accounts have correct shell configurations.

---
*Part of an ongoing Azure incident simulation series — 
see [repo README] for context.*