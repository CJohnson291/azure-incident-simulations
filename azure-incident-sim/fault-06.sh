#!/bin/bash

az network vnet update \
  --resource-group rg-incidentsim \
  --name vnet-incidentsim \
  --dns-servers 10.50.1.254 \
  --output none
