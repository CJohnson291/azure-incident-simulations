# Incident Report: Scheduled Task Creation (Nightly Disk Space Check)

**Scenario #:** 25
**Date:** 03/11/2026
**Environment:** Windows Server 2022 VM (vm-win-app1)
**Severity (self-assessed):** Low
**Time to resolution:** Approximately 1 hour

---

## 1. Ticket

TICKET#025 — BAU Task
Raised by: Infrastructure Team
Time: 09:30

"We need a scheduled task on vm-win-app1 that runs a disk space check every night at 2am and logs the output to a file. Run it as SYSTEM so it doesn't depend on a logged-in user. Once created, trigger it manually to prove it works, confirm the log file contains the output, and document the steps."

## 2. Initial Triage

BAU request, no fault to triage. The requirements were:
- A script that records the date and free space on C: to a log file
- A scheduled task that runs the script daily at 2am as SYSTEM
- Evidence: task registered, manual run, log file contents

## 3. Investigation

N/A, BAU request. The cmdlets were identified with `Get-Command *ScheduledTask*`. The four needed were `New-ScheduledTaskAction`, `New-ScheduledTaskTrigger`, `New-ScheduledTaskPrincipal` and `Register-ScheduledTask`.

## 4. Root Cause

N/A, BAU request. One issue arose during testing: the first check returned no log file. The script had been saved from Notepad as `diskcheck.ps1.txt`, so the task had no script to run. See Resolution.

## 5. Resolution

**The script**, saved as `C:\Scripts\diskcheck.ps1`:

```powershell
$logDir  = 'C:\Logs'
$logFile = Join-Path $logDir 'diskcheck.log'

if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

$date    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$vol     = Get-Volume -DriveLetter C
$freeGB  = [math]::Round($vol.SizeRemaining / 1GB, 2)
$totalGB = [math]::Round($vol.Size / 1GB, 2)

"$date  C: free $freeGB GB of $totalGB GB" | Out-File -FilePath $logFile -Append
```

**The task**, registered from an administrator PowerShell:

```powershell
$action    = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\diskcheck.ps1'
$trigger   = New-ScheduledTaskTrigger -Daily -At '2:00AM'
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable
$task      = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask -TaskName 'DiskSpaceCheck' -InputObject $task
```

**The fix for the missing log:** the script file had the wrong extension, so it was renamed:

```powershell
Rename-Item C:\Scripts\diskcheck.ps1.txt diskcheck.ps1
```

## 6. Verification

The script was run directly once to confirm it worked, and the resulting log was deleted so the final evidence would come from the scheduled task. The task was then started manually:

```powershell
Remove-Item C:\Logs\diskcheck.log
Start-ScheduledTask -TaskName 'Diskspacecheck'
Get-ScheduledTaskInfo -TaskName 'Diskspacecheck'
Get-Content C:\Logs\diskcheck.log
```

Output:

```
LastRunTime        : 11/3/2026 12:18:18 PM
LastTaskResult     : 0
NextRunTime        : 11/4/2026 2:00:00 AM
NumberOfMissedRuns : 0
TaskName           : Diskspacecheck
TaskPath           :
PSComputerName     :

2026-11-03 12:18:10  C: free 113.11 GB of 126.51 GB
```

- `LastTaskResult : 0` shows the task completed successfully.
- The log file was recreated after being deleted, so the line was written by the scheduled task.
- `NextRunTime` shows the next scheduled run at 02:00 on 04/11/2026.
- The log timestamp (12:18:10) and `LastRunTime` (12:18:18) differ by 8 seconds. This was not investigated.



## 7. What Was Actually Changed (Reveal)

No fault was injected. This was a planned BAU task, and the exercise tested building a scheduled task end to end:
- The action launches `powershell.exe` with `-File` pointing at a script. It does not contain PowerShell commands itself.
- The principal runs the task as SYSTEM, so it does not depend on a logged-in user.
- `-StartWhenAvailable` runs a missed task when the VM next starts. This matters because the VM is deallocated between sessions.
- Registering a task does not validate the script path, so a task can register without error and still fail at runtime. The manual run and `LastTaskResult` check are what prove it works.

## 8. Learning Notes

- **What went well:** The four-part structure (action, trigger, principal, settings) was understood quickly, and the final run worked first time once the file was renamed.

- **What took longer than expected:** Notepad saved the script as `diskcheck.ps1.txt`, so the first check found no log. Next time I will set "Save as type" to All Files, or put the filename in quotes. A second delay was the first draft of the task: the action used a non-existent `Run` parameter, commands that belong in a script file, and several typos in cmdlet names and variable names.

- **Hints used:** Substantial. The structure of the action (launch `powershell.exe` with a script file), the corrected cmdlet names, and the script were provided after my first drafts. The troubleshooting steps for the missing log were also provided.

- **Cost lesson:** The VM was deployed before the script was written, and it ran while I drafted. Writing and reviewing code needs no cloud resources. Going forward, the order is ticket, write and review, then deploy and test.

- **What I'd check first if this happened again:** Confirm the script file exists with the correct extension (`Get-ChildItem C:\Scripts`), run the script manually, then run the task and check `LastTaskResult`.

- **Prevention and improvements:** The log appends every night with no rotation, so it needs a retention step (for example, deleting entries older than 90 days). The task should be monitored for failures. The Task Scheduler operational log records task results, and an alert on a non-zero result would catch a silent failure. Disk space is best monitored at the platform level with an Azure Monitor alert, so this task is a supplement rather than a replacement.

---
*Part of an ongoing cloud incident simulation series (Azure & AWS) — see [repo README] for context.*