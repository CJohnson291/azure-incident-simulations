# Incident Report: InboundTraffic Rule

**Scenario #:** [AWS01]
**Date:** [15/07/2026]
**Environment:** [AWS VM - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [15minutes]

---

## 1. Ticket

AWS TICKET #001 — Priority: High
Reported by: Sarah (Operations)**
Time: 09:14**
"Hi, we've just had a report from a customer that App 1 is completely unreachable. They were using it fine yesterday. Our monitoring is also showing it as down. Can you investigate and get it back up?"

## 2. Initial Triage

Checked instance health and status - healthy and running

## 3. Investigation

Checked security group rules for inbound traffic

## 4. Root Cause

Inbound http rule was missing

## 5. Resolution

Using AWS console to add http inbound rule

I could have also ran the following command to achieve the same

aws ec2 authorize-security-group-ingress \
  --group-id sg-0304b0c46b7cdbe7a \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region eu-west-2

## 6. Verification

curl ip - healthy return
Verified in browser - IP address returned App status, meaning inbound rule has taken effect and resolved the issue

## 7. What Was Actually Changed (Reveal)

AWS Scenario 01 — Reveal:
The fault removed the HTTP inbound rule from the Security Group using:

bashaws ec2 revoke-security-group-ingress \
  --group-id sg-0304b0c46b7cdbe7a \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region eu-west-2

## 8. Learning Notes

- What went well

Identified possible cause quickly and knew where to check

- What took longer than expected, and why

N/A

- Any hints used (Hint 1 / Hint 2 / Full walkthrough) and what they revealed

Command prompt alternative instead of using the console

- What you'd check first if this happened again

Same process as above

- Prevention: how this could be avoided or caught sooner in a real environment
  (e.g. monitoring, alerting, change control)

AWS Config rules (restricted-ssh, vpc-sg-open-only-to-authorized-ports) alert on security group changes. 
---

Add a comparison note in learning notes: "AWS Security Groups are conceptually identical to Azure NSGs — inbound/outbound rules, protocol/port/source. Key difference: Security Groups are associated directly to the EC2 instance, not to a NIC or subnet separately. This means no manual NIC association step required after deployment — a recurring issue in the Azure environment.


*Part of an ongoing Azure incident simulation series — see [repo README] for context.*
