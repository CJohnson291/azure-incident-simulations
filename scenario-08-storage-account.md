# Incident Report: BAU - Storage Account request    
**Scenario #:** [08]
**Date:** [26/06/2026]
**Environment:** [rg-incidentsim]
**Severity (self-assessed):** [Low]
**Time to resolution:** [15minutes]

---

## 1. Ticket

TICKET#008 — BAU Task

Raised by: Laura (IT Manager)

Time: 10:00
"Hi, we need to set up a new storage account in the rg-incidentsim resource group for a project team. They need a storage account with a container called 'project-data', with blob storage enabled. Access should be restricted so only our team's IP can access it — use your own IP for this exercise. Once done, confirm it's accessible from your IP and document the steps taken."

## 2. Initial Triage

N/A - BAU request

## 3. Investigation

N/A - BAU request

## 4. Root Cause

N/A - BAU request

## 5. Resolution

Created storage account projectteamsa in rg-incidentsim, created blob container project-data, configured public network access to 'Enable from selected networks' with IP 86.130.0.x/32 added to the IPv4 allowlist


## 6. Verification

Used the CLI to verify network rules had been correctly applied

az storage account show \
  --name projectteamsa \
  --resource-group rg-incidentsim \
  --query networkRuleSet \
  --output json

Identified that Cloud Shell routes through Microsoft IPs - key learning point, kept receiving error when trying to test access

Tested locally (terminal) and received an empty output. Empty means storage account is empty (which is correct) therefore IP restriction correctly applied

## 7. What Was Actually Changed (Reveal)

This was a BAU provisioning task rather than a fault injection — no hidden changes were made. The task required:

Create a storage account in rg-incidentsim
Create a blob container called project-data
Restrict access to a specific IP via storage account firewall
Verify both allowed and denied access states

## 8. Learning Notes

- What went well
Creating the SA was straight forward and applying IP restriction

- What took longer than expected, and why

Testing the IP restriction took longer than expected because teh Azure CLI uses Microsoft IP's so I was receiving an error and thought I must have done it incorrectly. Once I realised to test locally through terminal, it proved that my configuration was correct

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

Claude explanation of CLI using Microsoft IPs

- What you'd check first if this happened again

Always test storage firewall rules from local terminal, not Cloud Shell — Cloud Shell routes through Microsoft datacenter IPs which won't match your configured IP allowlist

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

A self-service automation could prompt the requesting team for key details before provisioning — access frequency (to determine appropriate storage tier: Hot, Cool, or Archive), required retention period, expected data sensitivity (to enforce encryption or private endpoint requirements), and whether public access is needed at all. This reduces manual effort, enforces consistency, and ensures storage accounts are right-sized and correctly secured from creation rather than retrofitted later.
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
