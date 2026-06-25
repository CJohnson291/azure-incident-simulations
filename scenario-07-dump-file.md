# Incident Report: Large File Dump

**Scenario #:** 07
**Date:** 25/06/2026
**Environment:** App 1 - baseline VM
**Severity (self-assessed):** High
**Time to resolution:** 45 minutes

---

## 1. Ticket

TICKET #007 — Priority: High

Reported by: Rachel (Support)

Time: 13:45

"Hi, App 1 has started behaving really strangely — it was working fine 
this morning but now it's either returning errors or responding very 
slowly. The VM shows as running but something seems off. We're also 
seeing some write failures in our logs. Can you take a look?"

## 2. Initial Triage

Ticket mentioned write failures and slow response — pointed toward a 
disk or resource issue rather than a network or service problem. 
Checked CPU and disk metrics first as the most likely culprits.

## 3. Investigation

Checked CPU usage via Azure Monitor — highest reading was 11.025%, 
not high enough to explain the symptoms.

```bash
az monitor metrics list \
  --resource vm-incidentsim-app1 \
  --resource-group rg-incidentsim \
  --resource-type Microsoft.Compute/virtualMachines \
  --metric "Percentage CPU" \
  --interval PT5M \
  --output table
```

Checked disk IOPS — highest reading 0.6%, also unremarkable.

```bash
az monitor metrics list \
  --resource vm-incidentsim-app1 \
  --resource-group rg-incidentsim \
  --resource-type Microsoft.Compute/virtualMachines \
  --metric "OS Disk IOPS Consumed Percentage" \
  --interval PT5M \
  --output table
```

Checked disk usage — 19% used on root filesystem. Not full, but 
continued investigating as metrics didn't explain the symptoms.

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "df -h"
```

Listed the log directory sorted by newest files first — this 
immediately surfaced a suspicious file `fillup.tmp` written at 07:01, 
owned by root, sitting in `/var/log/`.

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "ls -lt /var/log/ | head -20"
```

Confirmed file size — 3.5GB, root owned, written at the same time 
symptoms began.

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "ls -lh /var/log/fillup.tmp"
```

## 4. Root Cause

A 3.5GB junk file (`fillup.tmp`) was written to `/var/log/` by root at 
07:01, consuming a significant portion of available disk space and 
causing write failures and slow response times as the filesystem 
approached capacity.

## 5. Resolution

Deleted the file and confirmed disk space was recovered.

```bash
az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "rm /var/log/fillup.tmp && df -h"
```

Post-deletion disk usage dropped from 19% to 7%, confirming the file 
was the cause.

## 6. Verification

`df -h` output after deletion confirmed root filesystem dropped from 
5.3GB used to 1.9GB used (19% → 7%). App confirmed healthy via curl 
returning expected HTML response.

## 7. What Was Actually Changed (Reveal)

The fault wrote a 3.5GB junk file using:

```bash
dd if=/dev/zero of=/var/log/fillup.tmp bs=1M count=3500
```

`dd` writes raw data from `/dev/zero` (an infinite stream of zeros) 
to a target file — commonly used to test disk performance or, as here, 
simulate unexpected disk space consumption. The file was written to 
`/var/log/` to blend in with legitimate log files, requiring log 
directory inspection to surface it.

## 8. Learning Notes

- **What went well:** Initial triage instinct was correct — ticket 
  mentioned write failures which pointed toward disk. Checking metrics 
  first before SSHing in was the right approach. Sorting the log 
  directory by newest files (`ls -lt`) immediately surfaced the 
  suspicious file — a technique worth using routinely.

- **What took longer than expected:** Initial disk metrics (19% used) 
  didn't clearly indicate a problem, which required continuing the 
  investigation beyond what the numbers suggested. The file was large 
  but hadn't fully filled the disk — in a real scenario with a smaller 
  disk this would have been more obvious.

- **Hints used:** No hints used. Additional command assistance sourced 
  from documentation during investigation — researching commands is 
  standard engineering practice.

- **What I'd check first if this happened again:** After confirming VM 
  and service status, run `df -h` immediately for any write failure 
  ticket, then `ls -lt /var/log/ | head -20` to surface recently 
  modified or created files.

- **Prevention:** 
  - Azure Monitor disk space alert (e.g. alert when OS disk usage 
    exceeds 80%) would catch this before it causes an outage
  - Log rotation policies (`logrotate`) prevent legitimate log files 
    growing unbounded
  - Change control and file integrity monitoring (Microsoft Defender 
    for Cloud) would alert on unexpected large file creation in 
    sensitive directories
  - Regular disk usage reviews as part of BAU health checks

---
*Part of an ongoing Azure incident simulation series — 
see [repo README] for context.*