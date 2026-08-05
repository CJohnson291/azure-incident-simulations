# Incident Report: Azure Backup and File Restore

**Scenario #:** 21
**Date:** 05/08/2026
**Environment:** Azure Linux VM + Recovery Services Vault
**Severity (self-assessed):** High
**Time to resolution:** 45 minutes

---

## 1. Ticket

TICKET#021 — BAU Task
Raised by: Infrastructure Team
Time: 09:00

"Hi, we've had a critical file deleted from App 1 by mistake earlier 
this morning — someone accidentally removed the index.html from 
/var/www/html during some maintenance work. The site is currently down. 
We have Azure Backup configured on the VM. Can you restore the VM from 
the most recent backup point and confirm the site is back up?"

## 2. Initial Triage

Confirmed site was down via curl — connection refused. Azure Backup 
was already configured on the VM with a recovery point available 
from 13:02.

## 3. Investigation

Located the Recovery Services Vault in the Azure portal. Confirmed 
a backup recovery point existed from 13:02 — taken before the 
file was deleted. Investigated restore options available for Linux VM.

## 4. Root Cause

Critical file (`/var/www/html/index.html`) accidentally deleted during 
maintenance, taking the site down. A valid recovery point existed from 
before the deletion.

## 5. Resolution

**Restore options investigated:**

**File Recovery (portal):** Not available for Linux VMs — File Recovery 
via portal is Windows-only. Linux requires a different approach.

**Replace existing (portal):** Greyed out for Linux — Azure does not 
support in-place disk replacement for Linux VMs via this method.

**Restore to new VM (portal):** Available — would spin up a brand new 
VM from the recovery point. Correct production approach when file 
contents are unknown or multiple files are affected. Takes 20-30 
minutes, then traffic would be swapped to the new VM.

**Manual recreation via Run Command:** Used in this simulation since 
file contents were known:

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "echo '<html><body><h1>App 1 - Status: OK</h1>
  <p>This is the baseline incident simulation environment.</p>
  </body></html>' | sudo tee /var/www/html/index.html && 
  sudo chown www-data:www-data /var/www/html/index.html"
```

## 6. Verification

curl returned the App 1 - Status: OK page confirming the site 
was restored.

## 7. What Was Actually Changed (Reveal)

This was a guided BAU task — no fault was injected. Azure Backup 
was configured, a manual backup triggered, and the restore process 
was investigated. The key learning was understanding the restore 
options available for Linux vs Windows VMs in Azure.

## 8. Learning Notes

- **What went well:** Located the recovery point quickly in the portal. 
  Correctly identified that a backup existed before the deletion event.

- **What took longer than expected:** Discovering that File Recovery 
  and Replace Existing are not available for Linux VMs — both options 
  are Windows-only. This is an important distinction worth knowing 
  before a real incident.

- **Hints used:** Full walkthrough — first time running a backup/restore 
  scenario. Key learning: always check what restore options are available 
  for your OS type before an incident occurs.

- **What I'd check first if this happened again:** Confirm a valid 
  recovery point exists before committing to a restore approach. Then 
  choose the restore method based on what's affected — single known 
  file (recreate), unknown/multiple files (restore to new VM), 
  catastrophic failure (full VM restore to new VM).

- **Prevention:** Azure Backup with daily recovery points and soft 
  delete enabled on the vault (protects backup data from accidental 
  deletion for 14 days). RBAC to restrict who can delete files from 
  production VMs. For frequently changed files, Azure File Shares 
  with snapshots provide easier file-level restore than VM backup. 
  A Windows VM restore scenario is planned to demonstrate the full 
  portal-based File Recovery flow.

---
*Part of an ongoing cloud incident simulation series (Azure & AWS) — 
see [repo README] for context.*