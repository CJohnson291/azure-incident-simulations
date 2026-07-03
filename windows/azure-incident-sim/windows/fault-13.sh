#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "Stop-Service -Name TermService -Force; Set-Service -Name TermService -StartupType Disabled" \
  --output none
