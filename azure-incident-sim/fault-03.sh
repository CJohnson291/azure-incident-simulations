#!/bin/bash
ssh -i ~/.ssh/id_rsa_azure -o StrictHostKeyChecking=no azureuser@20.61.108.77 "sudo chmod 700 /var/www/html"
