#!/bin/bash
ssh -i ~/.ssh/id_rsa_azure -o StrictHostKeyChecking=no azureuser@20.229.237.181 "sudo systemctl stop nginx"
