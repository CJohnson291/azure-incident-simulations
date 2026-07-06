#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -Enabled False" \
  --output none
