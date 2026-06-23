# Incident Report: [Permission issue]

**Scenario #:** [03]
**Date:** [23/06/2026]
**Environment:** [App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [30 minutes]

---

## 1. Ticket

ICKET #003 — Priority: High

Reported by: James (Support)

Time: 14:05
"Hey, App 1 is returning an error page to customers — not fully down like last time, something is coming back but it's not the app. VM looks healthy in the portal, nothing obvious on my end. Can you take a look?"

## 2. Initial Triage

Confirmed VM was running
Confirmed the error message returned by the app - 403 forbidden

## 3. Investigation

After intial checks, confirmed VM is up, service is up, but access forbidden. 403 points to permissions issue

## 4. Root Cause

nginx error log showed Permission denied on /var/www/html/index.html. The directory ownership had been changed to root:root with 750 permissions, preventing nginx worker processes (running as www-data) from reading the files." Keep the log as supporting evidence below that explanation

Permissions from http is forbidden

## 5. Resolution

sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html 

## 6. Verification

curl http://20.61.108.77
<!DOCTYPE html>
<html>
  <head><title>App 1</title></head>
  <body>
    <h1>App 1 - Status: OK</h1>
    <p>This is the baseline incident simulation environment.</p>
  </body>
</html>

Confirmed via browser that the 403 forbidden error no longer shows and app shows as expected

## 7. What Was Actually Changed (Reveal)

The fault was two commands run via Azure Run Command:

bashsudo chmod 750 /var/www/html 
sudo chown root:root /var/www/html

This did two things:

Changed ownership of /var/www/html from www-data to root
Changed permissions to 750 — meaning only the owner (root) had full access, group had read/execute, and others had nothing

Nginx worker processes run as www-data — so after the change, they could no longer read the directory contents, resulting in a 403 Forbidden rather than a full outage (nginx itself was fine, it just couldn't serve the files).

## 8. Learning Notes

- What went well

Quickly idetified it was a permissions issue, based on 403 error message

- What took longer than expected, and why

Linux commands - instead of trying to find the right commands again, I could have created notes or a runbook of any commands I have previously used. This can increase my effeciency in resolving the issue. engineer-notes.md has now been created and will be updated as I progress

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

No hints used, other than confirmed my command would be correct

- What you'd check first if this happened again

engineer-notes.md to find commands to help identify the permission 

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Change control would catch this before deployment. An Azure Monitor availability alert hitting port 80 would detect the 403 within minutes. File integrity monitoring (e.g. Microsoft Defender for Cloud) could also alert on unexpected permission changes to web directories

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
