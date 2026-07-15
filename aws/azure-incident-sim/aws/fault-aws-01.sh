#!/bin/bash

# Get the security group ID from terraform output
SG_ID=$(terraform output -raw security_group_id)

# Remove the HTTP allow rule
aws ec2 revoke-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region eu-west-2
