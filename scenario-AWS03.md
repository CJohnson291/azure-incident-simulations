# Incident Report: [nginx permissions]

**Scenario #:** [03]
**Date:** [16/07/2026]
**Environment:** [AWS EC2 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [15 minutes]

---

## 1. Ticket

Hey, App 1 is returning an error page to customers — not fully down like last time, something is coming back but it's not the app. Instance looks healthy in the console, nothing obvious on my end. Can you take a look?

## 2. Initial Triage

curl IP showed 403 forbidden, this suggests permissions based for nginx service

## 3. Investigation

Using AWS Systems Manager I ran the following command to check permissions

ls -la /var/www/html

## 4. Root Cause

nginx permissions for root user only, so any http requests would be rejected

## 5. Resolution

Using AWS SSM again ran the following command to change the permissions

sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 755 /var/www/html

## 6. Verification

curl output shows as healthy

## 7. What Was Actually Changed (Reveal)

Reveal: 

The fault changed ownership of /var/www/html to root:root and set permissions to 700 — meaning only root could access it. nginx worker processes run as www-data so couldn't read the directory, returning 403 Forbidden.

Same root cause as Azure scenario 3 — identical fix (chown + chmod), same diagnostic approach (403 → check permissions), just using AWS SSM Run Command instead of Azure Run Command.

## 8. Learning Notes

- **What went well:** 403 error code immediately suggested permissions 
  rather than network or service — correct instinct. Used AWS SSM Run 
  Command console to investigate without needing SSH access.

- **What took longer than expected:** Unfamiliarity with AWS SSM console 
  interface — finding Run Command and entering commands correctly took 
  longer than the equivalent Azure Run Command.

- **Hints used:** Command provided to check and fix permissions.

- **What I'd check first if this happened again:** curl the IP first to 
  get the error code — 403 = permissions, 503 = config, timeout = 
  network. Then `ls -la /var/www/html` to confirm ownership and 
  permission flags.

- **Prevention:** AWS Config rule to detect unexpected permission changes. 
  CloudTrail logs API calls but not OS-level changes — CloudWatch agent 
  with file integrity monitoring would catch changes to `/var/www/html`. 
  Change control over any manual file system changes on production instances.
---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
