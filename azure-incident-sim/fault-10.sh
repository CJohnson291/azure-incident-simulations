#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo usermod -s /usr/sbin/nologin azureuser" \
  --output none
