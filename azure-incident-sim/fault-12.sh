#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo bash -c 'echo \"server { listen 80; location / { return 503; } }\" > /etc/nginx/sites-available/default && sudo systemctl reload nginx'" \
  --output none
