# Incident Report: [Increase Disk space]

**Scenario #:** [24]
**Date:** [02/11/2026]
**Environment:** [WindowsVM]
**Severity (self-assessed):** [Low]
**Time to resolution:** [45minutes]

---

## 1. Ticket

TICKET#024 — BAU Task
Raised by: Infrastructure Team
Time: 10:00

“Drive C: on vm-win-app1 is running low on space. Please increase the OS disk to 256 GB under change control. Mute monitoring alerts for the maintenance window, restart the VM once the disk is resized, and confirm Windows can see and use the new space. Provide a screenshot as evidence, then unmute alerts and confirm the server is healthy.”

## 2. Initial Triage

Checked VM is currently running, RDP'd in and checked disk size by running PowerShell command

Get-Volume -DriveLetter C

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining      Size
----------- ------------ -------------- --------- ------------ ----------------- -------------      ----
C           Windows      NTFS           Fixed     Healthy      OK                    112.84 GB 126.51 GB


## 3. Investigation

Screenshot of powershell command to show disk size before change is implemented


## 4. Root Cause

BAU task - simulated disk space requirement

## 5. Resolution

Prerequisite: created alert rule `alert-vm-win-app1-cpu` (Percentage CPU, average, greater than 80%, email action group) so there was an alert to mute.

1. Muted alerts: created an alert processing rule scoped to `vm-win-app1` with the action "Suppress notifications", schedule Always.
2. Deallocated the VM:

```
az vm deallocate --resource-group rg-incidentsim-windows --name vm-win-app1
```

3. Found the OS disk name, then resized it to 256 GB:

```
az vm show --resource-group rg-incidentsim-windows --name vm-win-app1 --query storageProfile.osDisk.name --output tsv
az disk update --resource-group rg-incidentsim-windows --name <os-disk-name> --size-gb 256
```

4. Started the VM and reconnected over RDP:

```
az vm start --resource-group rg-incidentsim-windows --name vm-win-app1
```

5. Extended the C: partition inside Windows:

```powershell
$max = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
Resize-Partition -DriveLetter C -Size $max
```

6. Unmuted: deleted the alert processing rule. The alert rule itself was untouched.



## 6. Verification

## 6. Verification

Re-ran `Get-Volume -DriveLetter C` after the VM restart and partition extension:

```
DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining      Size
----------- ------------ -------------- --------- ------------ ----------------- -------------      ----
C           Windows      NTFS           Fixed     Healthy      OK                    241.84 GB 255.51 GB
```

| | Size | Free |
|---|---|---|
| Before | 126.51 GB | 112.84 GB |
| After | 255.51 GB | 241.84 GB |

Both figures increased by 129 GB, confirming Windows is using the full new capacity. The volume reports Healthy and OK, and RDP access was restored after the restart.

Unmute: the alert processing rule was deleted. The alert rule `alert-vm-win-app1-cpu` showed a status of Succeeded in `az resource list` and was visible again in the portal.


## 7. What Was Actually Changed (Reveal)

This was a guided BAU change, so no fault was injected. Nothing was hidden for you to find. The skill being tested was the order of operations in a planned disk uplift.

The change sequence

Capture “before” evidence: Get-Volume showed C: at 126.51 GB with 112.84 GB free.
Create the alert rule, then the alert processing rule that suppresses notifications for the VM.
Deallocate the VM. az vm stop is not enough, because the VM stays allocated and Azure won’t resize the OS disk.
Resize the OS disk to 256 GB with az disk update, using the generated OS disk name rather than the VM name.
Start the VM and reconnect over RDP.
Extend the C: partition inside Windows with Get-PartitionSupportedSize and Resize-Partition.
Remove the alert processing rule and confirm the alert rule is still enabled.

Why the order matters

Mute before the change. Otherwise the deallocation can trigger the notifications the mute exists to prevent.
Deallocate, not stop. A stopped but allocated VM keeps its hardware reservation and blocks the disk resize.
Resize in Azure, then extend in Windows. These are two separate layers. Azure enlarges the disk, but Windows keeps the old partition size until you extend it.
Unmute and verify last. A forgotten suppression rule is the risk, since it silently hides real alerts afterwards.

## 8. Learning Notes

- What went well
Process was relatively easy to follow and commands did not conjure any unexpected errors
- What took longer than expected, and why
Creating the alert and muting it - this was new to me and I expected an alert to simply have a mute option rather than creating a processing rule, but great experience either way
- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed
Powershell command assistance required to extend the partition type
- What you'd check first if this happened again
I would follow the same process as this worked very well
- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

- **What went well:** The sequence was easy to follow once the order was clear, and the partition extension worked as expected.
- **What took longer than expected:** Alert muting was new to me. I expected a mute option on the alert rule itself, not a separate alert processing rule. 
- **Hints used:** My first attempt used `az vm stop` and the VM name as the disk name. Both were corrected before running (deallocate, and look up the generated OS disk name). The PowerShell for extending the partition was provided.
- **What I'd check first if this happened again:** Confirm the alert rule exists and is enabled, check the subscription filter on the Monitor lists, and confirm a recent backup or snapshot before resizing. Managed disks can only be enlarged, never shrunk.
- **Prevention:** Run disk changes under change control with a rollback plan. Alert on free space at around 80% used so the uplift is planned rather than urgent. Finish every maintenance window by checking alert state and removing suppression rules.
---
*Part of an ongoing Azure + AWS incident simulation series — see [repo README] for context.*
