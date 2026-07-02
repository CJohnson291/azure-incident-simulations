# Incident Report: Outbound NSG rule
**Scenario #:** 11
**Date:** [02/07/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [Medium]
**Time to resolution:** [20 minutes]

---

## 1. Ticket

TICKET#011 — Priority: High

Reported by: Dev team

Time: 14:30
"Hi, something's wrong with App 1 — the site is still up and customers can reach it fine, but our deployment pipeline is failing again. The VM can't seem to reach anything external — package updates are failing, can't pull from GitHub, can't reach any external APIs. Started happening about an hour ago. Can you investigate?"

## 2. Initial Triage

Ticket mentioned customers are able to reach the VM, but the VM cannot reach anything externally. I went straight into the NSG rule list in Azure Portal

## 3. Investigation

Checked outbound rules in the associated NSG in both the VM and subnet. Both had Outbound Deny rule set, at the highestest priority.

## 4. Root Cause

Outbound NSG rule called Block-Outbound-Internet at priority 100, denies all outbound traffic

## 5. Resolution

Deleted outbound Deny rule from NSG

## 6. Verification

# Check outbound NSG rules specifically
az network nsg rule list \
  --resource-group rg-incidentsim \
  --nsg-name nsg-incidentsim-app1 \
  --output table

# Test outbound connectivity from VM
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "curl -s --connect-timeout 5 https://github.com && echo 'reachable' || echo 'unreachable'"

## 7. What Was Actually Changed (Reveal)

The fault added an outbound NSG rule called Block-Outbound-Internet at priority 100, denying all outbound TCP traffic to the Internet service tag. Since it was priority 100 — higher than any default allow rules — it blocked all outbound connections from the VM regardless of destination.

## 8. Learning Notes

- What went well

Identifying the root cause took only a few minutes

- What took longer than expected, and why

Again, knowing the command to verify - this shows the importance of engineer notes for quick referencing in future incidents

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

N/A

- What you'd check first if this happened again

Check both inbound and outbound NSG rules — outbound is easy to overlook when inbound traffic appears fine. The ticket symptom (customers unaffected but VM can't reach internet) is a reliable indicator of an outbound block.

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Change control over NSG rule changes. Azure Monitor alert on NSG rule additions/modifications via Activity Log. Any outbound deny rule at priority 100 should trigger an immediate review — it's an unusually aggressive rule that would rarely appear through normal operations.
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
