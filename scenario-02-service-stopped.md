# Incident Report: [Linux Service Stopped]

**Scenario #:** 02
**Date:** [22/06/2026]
**Environment:** [e.g. App 1 - baseline VM]
**Severity (self-assessed):** [Low / Medium / High]
**Time to resolution:** [25 minutes]

---

## 1. Ticket

TICKET #002 — Priority: High

Reported by: Marcus (Support Lead)

Time: 10:32
"Hey, App 1 is down again — customers are getting nothing when they try to access it. The VM looks like it's running fine in the portal though. Can you take a look? We need this back up quickly."

## 2. Initial Triage

In Azure Portal, confirmed VM was running

## 3. Investigation

Confirmed VM status in Azure portal - VM running
Browser timing out
Ran the following to check services 

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo systemctl status nginx"

## 4. Root Cause

nginx web server process stopped on the VM. The VM and network were healthy, only the application service was down

## 5. Resolution

used local SSH initially, identified Run Command as the preferred method going forward

## 6. Verification

Accessed http://20.229.237.181 in browser, App 1 - Status OK page returned confirming nginx was running

## 7. What Was Actually Changed (Reveal)

Scenario 02 — Reveal:
The fault was a single bash command run over SSH that stopped the nginx service:

bashsudo systemctl stop nginx

That's it — the VM was fully running, the NSG was fine, the network was fine. Just the web server process itself was stopped. Your diagnosis was correct — you identified the VM was up but the service was down, which is exactly the right conclusion. The gap was purely tooling familiarity (SSH vs Run Command, systemctl syntax) rather than diagnostic thinking, which was sound.

## 8. Learning Notes

- What went well
Confirmed VM was up and NSG correct

- What took longer than expected, and why
Experience gap with Linux services - not familiar with the CLI command required to check this

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

1 hint. I knew the VM was working, NSG rules looked correct too but was unsure how to check a Linux service. I'm familiar with Windows, so would have expected to RDP onto a Windows VM and look at services. 

- What you'd check first if this happened again

The curl http://IP test from outside the VM is always a good first step — "connection refused" vs "connection timed out" tells you different things (refused = VM up, service down; timed out = likely NSG/network issue

systemctl status <service> is the go-to command for any "app is up but something isn't working" Linux scenario — nginx, apache, any custom service
- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

An Azure Monitor alert on the VM's HTTP availability (a simple ping/availability test hitting port 80) would have caught this within minutes. Auto-restart via systemctl enable nginx would also prevent recurrence after a reboot
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
