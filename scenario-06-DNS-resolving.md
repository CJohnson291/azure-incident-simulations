# Incident Report: DNS stopped resolving

**Scenario #:** 06
**Date:** [24/06/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [ High]
**Time to resolution:** [15 minutes]

---

## 1. Ticket

TICKET #006 — Priority: High

Reported by: Tom (DevOps)

Time: 09:22
"Hey, something odd is happening with App 1 — the site itself is still responding but we're getting reports that the VM can't resolve external hostnames. Our deployment pipeline is failing because the VM can't reach GitHub to pull packages. The app is up but anything requiring outbound name resolution from the VM is broken. Can you investigate?"

## 2. Initial Triage

Confirmed web app was working via browser

## 3. Investigation

Checked DNS settings on the NIC in Azure portal 

## 4. Root Cause

VNet DNS servers were configured to point to a non-existent IP (10.50.1.254) within the VNet, causing all DNS queries from the VM to fail silently"

## 5. Resolution

Changed DNS settings to custom, set DNS IP to 8.8.8.8

## 6. Verification

Azure CLI - tested VM can ping Google DNS, then tested VM nslookup 

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \   
  --command-id RunShellScript \   
  --scripts "ping -c 4 8.8.8.8"

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "nslookup github.com"

## 7. What Was Actually Changed (Reveal)

The fault set the VNet's DNS servers to 10.50.1.254 — a non-existent IP address within the VNet. This meant any DNS query from the VM went to a server that didn't exist, causing name resolution to silently fail. IP connectivity was fine (hence ping to 8.8.8.8 worked), but anything requiring a hostname lookup (GitHub, package repos, external APIs) would time out.

## 8. Learning Notes

- What went well

Understanding it was a DNS issue

- What took longer than expected, and why

Understanding the difference between IP connectivity (ping) and name resolution (nslookup) — ping to an IP bypasses DNS entirely, so a successful ping doesn't rule out a DNS issue

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

No hints user

- What you'd check first if this happened again

DNS settings in the NIC, originally I tried to find it in the VM settings rather than the NIC

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

  Azure Monitor DNS resolution alerts, and change control over VNet configuration changes. VNet-level changes affect every resource in that VNet simultaneously — high blast radius.


DNS issues and network connectivity issues look similar on the surface but are different layers — always test both separately (ping IP vs nslookup hostname)

VNet DNS settings in Azure override the VM's own DNS config — always check VNet-level settings first when name resolution fails across multiple resources

nslookup and ping are your two essential outbound connectivity tests 

Azure's default DNS (168.63.129.16) handles internal Azure resolution — using a custom DNS server means you take on responsibility for what it resolves
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
