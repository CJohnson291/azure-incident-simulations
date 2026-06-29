#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --command-id RunShellScript \
  --scripts "sudo sed -i 's/listen 80 default_server;/listen 8080 default_server;/' /etc/nginx/sites-available/default && sudo systemctl reload nginx" \
  --output none
