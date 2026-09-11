# Incident Report: [WeakCiphers]

**Scenario #:** [16]
**Date:** [14/07/2026]
**Environment:** [WindowsVM]
**Severity (self-assessed):** [High]
**Time to resolution:** [20minutes]

---

## 1. Ticket

TICKET#016 — BAU Task
Raised by: Security Team**
Time: 10:30**
"Following last week's TLS version remediation, the pen test team has flagged a second finding on the same Windows VM. Weak cipher suites are enabled — specifically RC4 and DES variants. These are cryptographically broken and must be disabled immediately. Please investigate the current cipher configuration, disable all weak ciphers, and document the changes. A reboot will be required."

## 2. Initial Triage

Googled RC4 and DES - AI prompt explained these are OS settings of the VM

## 3. Investigation

Checked ciphers currently used in the VM

```
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
\$basePath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
@('RC4 128/128','RC4 56/128','RC4 40/128','DES 56/56','AES 128/128','AES 256/256') | ForEach-Object {
    \$props = Get-ItemProperty -Path \"\$basePath\\\$_\" -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        Cipher = \$_
        Enabled = \$props.Enabled
    }
} | Format-Table -AutoSize
"
```

## 4. Root Cause

RC4 (128/128, 56/128, 40/128) and DES 56/56 cipher suites were enabled via Windows SCHANNEL registry keys. These are cryptographically broken — RC4 is banned by RFC 7465, DES is brute-forceable with modern hardware. AES was not explicitly enabled

## 5. Resolution

Ran the following command to disabled weak ciphers

```
az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
\$basePath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'

# Disable RC4 128/128
Set-ItemProperty -Path \"\$basePath\RC4 128/128\" -Name 'Enabled' -Value 0 -Type DWORD -Force

# Disable RC4 56/128
Set-ItemProperty -Path \"\$basePath\RC4 56/128\" -Name 'Enabled' -Value 0 -Type DWORD -Force

# Disable RC4 40/128
Set-ItemProperty -Path \"\$basePath\RC4 40/128\" -Name 'Enabled' -Value 0 -Type DWORD -Force

# Disable DES 56/56
Set-ItemProperty -Path \"\$basePath\DES 56/56\" -Name 'Enabled' -Value 0 -Type DWORD -Force

# Explicitly enable AES
New-Item -Path \"\$basePath\AES 128/128\" -Force
Set-ItemProperty -Path \"\$basePath\AES 128/128\" -Name 'Enabled' -Value 1 -Type DWORD -Force
New-Item -Path \"\$basePath\AES 256/256\" -Force
Set-ItemProperty -Path \"\$basePath\AES 256/256\" -Name 'Enabled' -Value 1 -Type DWORD -Force

Write-Host 'Done'
"
```

## 6. Verification

Restarted VM via Azure portal, then ran the investigation command again which showed RC4 and DES are now disabled.

## 7. What Was Actually Changed (Reveal)

The fault enabled weak cipher suites via registry keys:
powershell# RC4 128/128, RC4 56/128, RC4 40/128, DES 56/56

New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -Force
New-ItemProperty ... -Name 'Enabled' -Value 1 -PropertyType DWORD -Force

Why these ciphers are dangerous:

RC4 — stream cipher, cryptographically broken since 2013, vulnerable to BEAST and RC4 bias attacks. Banned by RFC 7465.
DES — 56-bit key, brute-forceable in hours with modern hardware. Replaced by AES decades ago.

## 8. Learning Notes

- What went well

Understanding that cipher configuration is an OS-level registry setting, not an Azure portal setting. Following the same investigation pattern as scenario 15 (TLS version) translated directly to this scenario.

- What took longer than expected, and why

Initially searched the portal expecting to find cipher settings — same lesson as scenario 15. Cipher and TLS settings for IaaS VMs are always registry-based, not portal-visible

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

Command prompts

- What you'd check first if this happened again

Same process as above - use command line to check what ciphers are in use

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

Azure Policy can enforce TLS/cipher settings on PaaS services. For IaaS Windows VMs, Microsoft Security Compliance Toolkit and Group Policy should enforce cipher configuration at scale. Microsoft Defender for Cloud flags weak cipher configurations. Regular pen testing — exactly as in this scenario — remains the most reliable catch for IaaS misconfigurations.

---
*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
