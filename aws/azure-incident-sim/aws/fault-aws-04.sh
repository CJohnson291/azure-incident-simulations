#!/bin/bash

INSTANCE_ID=$(terraform output -raw instance_id)

aws ssm send-command \
  --instance-id $INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters commands=["sudo chmod 700 /var/www/html && sudo chown root:root /var/www/html"] \
  --region eu-west-2 \
  --output text
