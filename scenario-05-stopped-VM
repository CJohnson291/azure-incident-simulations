# Incident Report: Stopped VM
**Scenario #:** [05]
**Date:** [23/06/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [5 minutes]

---

## 1. Ticket

TICKET #005 — Priority: Critical

Reported by: David (Head of Operations)**

Time: 16:47
"App 1 is completely down — customers can't reach it at all and our monitoring is showing it as offline. This has been escalated to me directly. We need this back up immediately, what's the status?"

## 2. Initial Triage

Checked VM in Azure Portal

## 3. Investigation

Azure Portal showed the VM had been deallocated

## 4. Root Cause

VM had been deallocated

## 5. Resolution

Started VM again, via portal

## 6. Verification

Portal confirmed VM was running, checked app via public ip and recevied expected return

## 7. What Was Actually Changed (Reveal)

The fault deallocated the VM using:

bash 

az vm deallocate \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1

Deallocated means the VM is fully stopped and compute resources are released — different from just "stopped" in that Azure reclaims the underlying hardware, which also means the public IP can change on restart (which is why Static SKU matters in production).

## 8. Learning Notes

- What went well

Quickly located the issue

- What took longer than expected, and why

N/A

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

No hints used

- What you'd check first if this happened again

VM status

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Azure Monitor alert on VM power state change would catch this immediately. Activity Log alert on the deallocate operation would also identify who or what triggered it — critical for post-incident investigation in a real environment


Additional Notes

Stop (OS shutdown): VM is off but still allocated on hardware, you're still billed for compute
Deallocate: VM is off, hardware released, no compute billing, but public IP may change on restart


*Part of an ongoing Azure incident simulation series — see [repo README] for context.*

