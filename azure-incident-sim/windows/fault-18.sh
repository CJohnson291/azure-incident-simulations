#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
# Install IIS
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create a simple status page
New-Item -Path 'C:\inetpub\wwwroot\index.html' -ItemType File -Force
Set-Content -Path 'C:\inetpub\wwwroot\index.html' -Value '<html><body><h1>App 2 - Status: OK</h1><p>IIS baseline environment.</p></body></html>'

# Stop IIS to apply the fault
Stop-Service -Name W3SVC -Force
Set-Service -Name W3SVC -StartupType Disabled
" \
  --output none
