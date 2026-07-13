# Incident Report: [Pen Test - TLS version deprecated]

**Scenario #:** [15]
**Date:** [13/07/2026]
**Environment:** [Windows VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [e.g. 45 minutes]

---

## 1. Ticket

TICKET#015 — BAU Task
Raised by: Security Team
Time: 09:00
"Hi, our recent penetration test flagged that the Windows VM is accepting TLS 1.0 and TLS 1.1 connections, which are considered insecure and no longer compliant with our security policy. TLS 1.2 must be the minimum version. Please investigate the current TLS configuration, remediate, and document the changes made. A reboot will be required after changes.


## 2. Initial Triage

Windows VM found to be allowing depracated TLS version 1.0 and 1.1.

## 3. Investigation

Confirmed via CLI

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
@('TLS 1.0','TLS 1.1','TLS 1.2','TLS 1.3') | ForEach-Object {
    \$path = \"HKLM:\\SYSTEM\\CurrentControlSet\\Control\\SecurityProviders\\SCHANNEL\\Protocols\\\$_\\Server\"
    \$props = Get-ItemProperty -Path \$path -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Protocol = \$_
        Enabled = \$props.Enabled
        DisabledByDefault = \$props.DisabledByDefault
    }
} | Format-Table -AutoSize
"

## 4. Root Cause

Protocol  Enabled  DisabledByDefault
TLS 1.0   1        0                 ❌ ON
TLS 1.1   1        0                 ❌ ON  
TLS 1.2   0        1                 ❌ OFF
TLS 1.3   -        -                 ✅ ON (Windows default)

      TLS 1.0 and 1.1 enabled, 1.2 disabled - weak protocols being used

## 5. Resolution

Steps taken to fix it. 

```
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
# Disable TLS 1.0
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'Enabled' -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'DisabledByDefault' -Value 1 -PropertyType DWORD -Force

# Disable TLS 1.1
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'Enabled' -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Name 'DisabledByDefault' -Value 1 -PropertyType DWORD -Force

# Enable TLS 1.2
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value 0 -PropertyType DWORD -Force

# Enable TLS 1.3
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'Enabled' -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'DisabledByDefault' -Value 0 -PropertyType DWORD -Force
"
```

## 6. Verification

Restarted VM, waited 2-3 minutes then ran the same verification command in step 3

## 7. What Was Actually Changed (Reveal)

The fault enabled TLS 1.0 and 1.1 via registry keys under HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\ and disabled TLS 1.2 by setting Enabled=0, DisabledByDefault=1. TLS 1.3 was left at Windows default (no registry keys needed). Root cause analysis matched exactly.

## 8. Learning Notes

- What went well

I understood to check what mimimum standard TLS version is enabled

- What took longer than expected, and why

I was searching the portal to find this information but was unable. Prevously, I had seen this issue in a production enviroment and was able to see the enabled TLS version on the VM, because it was a SQL server. This is not always viewable in the portal 

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

Asked for commands to check the enabled / disabled version, then the command to force the required versions

- What you'd check first if this happened again

I would use the CLI commands first

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

  Azure Policy can enforce minimum TLS versions on PaaS services (storage accounts, SQL, App Service) at the platform level. For IaaS Windows VMs, Group Policy or a configuration management tool (Ansible, DSC) should enforce TLS settings at scale rather than manual per-VM registry changes. Regular pen testing and vulnerability scanning (Microsoft Defender for Cloud) would catch TLS misconfigurations proactively.

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
