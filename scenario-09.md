# Incident Report: [Short Title]

**Scenario #:** [09]
**Date:** [29/06/2026]
**Environment:** [e.g. App 1 - baseline VM]
**Severity (self-assessed):** [Low / Medium / High]
**Time to resolution:** [e.g. 45 minutes]

---

## 1. Ticket

TICKET#009 — Priority: High

Reported by: Marcus (Support Lead)

Time: 09:45
"Morning — App 1 is down again. Customers can't reach it. VM is showing as running, nothing obvious in the portal. This is the third time this week, starting to look bad. Can you get it back up and find out what's going on?"

## 2. Initial Triage

Checked VM status and browser responce - connection timed out

## 3. Investigation

Checked NSG port rules, SSH 22 and HTTP 80 set to Allow
Ran the following command to see what port NGINX was listening on

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo ss -tlnp | grep nginx"

## 4. Root Cause

nginx configured to listen on port 8080 instead of port 80, caused by a change to /etc/nginx/sites-available/default. The NSG only permits inbound traffic on port 80, so all requests timed out at the network layer before reaching nginx

## 5. Resolution

Changed listening port to 80 using the following command

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo sed -i 's/listen 8080 default_server;/listen 80 default_server;/' /etc/nginx/sites-available/default && sudo systemctl reload nginx"

## 6. Verification

curl http://20.16.68.149
<!DOCTYPE html>
<html>
  <head><title>App 1</title></head>
  <body>
    <h1>App 1 - Status: OK</h1>
    <p>This is the baseline incident simulation environment.</p>
  </body>
</html>

## 7. What Was Actually Changed (Reveal)

The fault changed nginx's listen directive from port 80 to 8080 in /etc/nginx/sites-available/default using sed, then reloaded nginx. VM healthy, service healthy, wrong port — a subtle fault that requires looking inside the VM config rather than at Azure-level resources.

## 8. Learning Notes

- What went well

The flow of what order to check traffic flow is becoming more and more obvious the more I practice these sims

- What took longer than expected, and why

I knew I needed to check what port it was listening on, but building on the experience with Linux I was unsure on the commands for this

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

AI prompt for checking listening port and changing port

- What you'd check first if this happened again

I would perform the same flow

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Change control over nginx configuration files. File integrity monitoring (e.g. Microsoft Defender for Cloud) would alert on unexpected changes to /etc/nginx/sites-available/default. An Azure Monitor availability alert hitting port 80 would catch this within minutes of the change being made.

Port 8080 is commonly used as an alternative HTTP port — worth remembering that a running service doesn't always mean it's accessible on the expected port. Always verify the listening port matches what the NSG and clients expect."
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
