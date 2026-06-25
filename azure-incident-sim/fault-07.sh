#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "dd if=/dev/zero of=/var/log/fillup.tmp bs=1M count=3500 2>/dev/null; echo done" \
  --output none
