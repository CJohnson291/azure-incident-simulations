#!/bin/bash

INSTANCE_ID=$(terraform output -raw instance_id)

aws ssm send-command \
  --instance-id $INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters commands=["sudo systemctl stop nginx"] \
  --region eu-west-2 \
  --output none
