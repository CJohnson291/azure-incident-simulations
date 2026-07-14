#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
# Enable weak cipher suites via registry
\$basePath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'

# Enable RC4 128/128
New-Item -Path \"\$basePath\RC4 128/128\" -Force
New-ItemProperty -Path \"\$basePath\RC4 128/128\" -Name 'Enabled' -Value 1 -PropertyType DWORD -Force

# Enable RC4 56/128
New-Item -Path \"\$basePath\RC4 56/128\" -Force
New-ItemProperty -Path \"\$basePath\RC4 56/128\" -Name 'Enabled' -Value 1 -PropertyType DWORD -Force

# Enable RC4 40/128
New-Item -Path \"\$basePath\RC4 40/128\" -Force
New-ItemProperty -Path \"\$basePath\RC4 40/128\" -Name 'Enabled' -Value 1 -PropertyType DWORD -Force

# Enable DES 56/56
New-Item -Path \"\$basePath\DES 56/56\" -Force
New-ItemProperty -Path \"\$basePath\DES 56/56\" -Name 'Enabled' -Value 1 -PropertyType DWORD -Force

Write-Host 'Weak ciphers enabled'
" \
  --output none
