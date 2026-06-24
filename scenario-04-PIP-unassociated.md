# Incident Report: PIP unassociated

**Scenario #:** [4]
**Date:** [23/06/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [5 minutes]

---

## 1. Ticket

TICKET #004 — Priority: High

Reported by: Priya (Operations)

Time: 11:15
"Hi, we've had a report that App 1 is completely unreachable again. VM shows as running in the portal, and as far as I can tell nothing was changed overnight. No scheduled maintenance either. Can you investigate?"

## 2. Initial Triage

VM status and website error message (connection timed out)

## 3. Investigation

Observed VM was running, website timeout occuring
Noticed in the portal, public IP was not showing. Investigated NIC, to spot missing association the PIP

## 4. Root Cause

The public IP was not associated to the NIC, mneaning traffic from the web would not work

## 5. Resolution

Re-associated the public IP to the NIC via portal 

## 6. Verification

The IP changing is expected — when you dissociate and reassociate a public IP, Azure can reassign it.
Entered new IP into browser to confirm remediation. App returned expected html

## 7. What Was Actually Changed (Reveal)

The fault dissociated the public IP from the NIC using:

bash 

az network nic ip-config update \
  --resource-group rg-incidentsim \
  --nic-name nic-incidentsim-app1 \
  --name internal \
  --remove publicIpAddress

VM was running, nginx was running, NSG was fine — but with no public IP attached there was no way for traffic to reach the VM from the internet.

## 8. Learning Notes

- What went well

Investigation was quick to locate issue and fix

- What took longer than expected, and why

N/A

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

No hints used

- What you'd check first if this happened again

Always check the association - this could easily be overlooked and the service could be presumed to be the issue

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

  Change control to monitor the dissacosiation 
  
 An Azure Monitor alert on NIC configuration changes or a simple HTTP availability test would catch this within minutes. In production, any DNS records or load balancer rules pointing to the old IP would also need updating after a reassociation — worth adding to a runbook checklist.

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
