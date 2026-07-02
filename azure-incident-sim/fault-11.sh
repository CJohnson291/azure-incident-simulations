#!/bin/bash

az network nsg rule create \
  --resource-group rg-incidentsim \
  --nsg-name nsg-incidentsim-app1 \
  --name Block-Outbound-Internet \
  --priority 100 \
  --direction Outbound \
  --access Deny \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes Internet \
  --destination-port-ranges '*' \
  --output none
