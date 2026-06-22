#!/bin/bash
az network nsg rule update \
  --resource-group rg-incidentsim \
  --nsg-name nsg-incidentsim-app1 \
  --name Allow-HTTP \
  --access Deny \
  --output none
