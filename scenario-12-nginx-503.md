# Incident Report: nginx Config Replaced - 503 Return

**Scenario #:** [12]
**Date:** [03/07/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [20 minutes]

---

## 1. Ticket

TICKET#012 — Priority: High

Reported by: Sarah (Operations)

Time: 10:15
"Hi, App 1 is returning an error to all customers — not fully down, 
something is coming back but it's definitely not the app. VM looks 
healthy, nothing obvious in the portal. Third time this week something's 
gone wrong. Can you investigate and fix?"

## 2. Initial Triage

Curl http to see what error was being returned - "503" error returned

## 3. Investigation

The site was returning a 503 error. VM was healthy, nginx was running. Checked the nginx configuration file to see if the issue was in how nginx was set up rather than the service itself. The config file had been replaced with a single line instructing nginx to return a 503 error for all requests instead of serving the application files

## 4. Root Cause

Any request over port 80 was instructed to return a 503 error code

## 5. Resolution

Restored the nginx configuration file to its correct content, instructing nginx to serve files from /var/www/html. Tested the config was valid, then reloaded nginx to apply it. Site returned to normal.

## 6. Verification

curl http again, confirmed to be healthy

## 7. What Was Actually Changed (Reveal)

The fault replaced the entire nginx config with a single line:

server { listen 80; location / { return 503; } }

This overwrote the legitimate config, causing nginx to return 503 for every request while the service itself remained running and healthy — hence the VM looking fine in the portal.

## 8. Learning Notes

- **What went well:** Correctly identified that 503 from nginx doesn't 
  mean the service is down or overloaded — it can be explicitly 
  configured to return it. Went straight to the config file once the 
  service was confirmed healthy, which was the right call.

- **What took longer than expected:** Restoring the nginx config via 
  Run Command took several attempts due to shell escaping issues with 
  special characters in the config file. In a real environment with SSH 
  access this would have been a 30-second file edit.

- **Hints used:** Explanation of 503 meaning and config restoration 
  commands provided with assistance.

- **What I'd check first if this happened again:** If the service is 
  running but returning an unexpected HTTP error code, read the 
  application config file immediately — `cat /etc/nginx/sites-available/default`. 
  The error code itself is a clue: 503 = service/config layer, 
  403 = permissions, 404 = file/routing.

- **Prevention:** File integrity monitoring on nginx config files — 
  Microsoft Defender for Cloud or a tool like AIDE on Linux would alert 
  on unexpected changes to `/etc/nginx/sites-available/default`. Change 
  control over config changes. Worth noting this fault could easily be 
  made malicious by replacing `return 503` with 
  `return 301 http://malicious-site.com` — making config integrity 
  monitoring a security concern, not just operational.
---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
