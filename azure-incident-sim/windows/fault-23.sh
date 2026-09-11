#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
# Install a simple service to simulate an application service
New-Item -Path 'C:\AppService' -ItemType Directory -Force
Set-Content -Path 'C:\AppService\app.ps1' -Value 'while(\$true) { Start-Sleep 60 }'

# Create and start a scheduled task as a stand-in service
Register-ScheduledTask -TaskName 'DataSyncService' -Action (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File C:\AppService\app.ps1') -RunLevel Highest -Force

# Stop the W3SVC (IIS) service to simulate the app being down
Stop-Service -Name W3SVC -Force
Set-Service -Name W3SVC -StartupType Disabled
" \
  --output none
