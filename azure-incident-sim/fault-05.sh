#!/bin/bash

az vm deallocate \
  --resource-group rg-incidentsim \
  --name vm-incidentsim-app1 \
  --output none
