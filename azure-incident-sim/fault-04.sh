#!/bin/bash

# Dissociate the public IP from the NIC
az network nic ip-config update \
  --resource-group rg-incidentsim \
  --nic-name nic-incidentsim-app1 \
  --name internal \
  --remove publicIpAddress \
  --output none
