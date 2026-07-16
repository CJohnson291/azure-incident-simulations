# Incident Report: [StoppedInstance]

**Scenario #:** [02]
**Date:** [16/07/2026]
**Environment:** [AWS EC2 App 1 - baseline VM]
**Severity (self-assessed):** [High]
**Time to resolution:** [5minutes]

---

## 1. Ticket

AWS TICKET#002 — Priority: Critical
Reported by: David (Head of Operations)**
Time: 16:47**
"App 1 is completely down — customers can't reach it at all and our monitoring is showing it as offline. This has been escalated to me directly. We need this back up immediately, what's the status?"

## 2. Initial Triage

Checked instance state 

## 3. Investigation

AWS console showed instance was stopped

## 4. Root Cause

Instance had been stopped

## 5. Resolution

Restarted instance through AWS console, showed as running and healthy

## 6. Verification

curl PIP - returned healthy

## 7. What Was Actually Changed (Reveal)

Reveal: The fault stopped the EC2 instance using:

bashaws ec2 stop-instances \
  --instance-ids i-036c97e47b362a2bc \
  --region eu-west-2

## 8. Learning Notes

- **What went well:** Instance state was immediately visible in the AWS 
  console — straightforward to identify and resolve.

- **What took longer than expected:** N/A — clean resolution.

- **Hints used:** None.

- **What I'd check first if this happened again:** AWS console EC2 
  dashboard — instance state is shown immediately. Alternatively via CLI:
  `aws ec2 describe-instances --instance-ids i-xxxx --query 
  "Reservations[0].Instances[0].State.Name"`

- **Prevention:** CloudWatch alarm on EC2 instance state change to 
  "stopped" — alerts within minutes. CloudTrail logs the `StopInstances` 
  API call showing who stopped it and when. AWS Config can enforce that 
  instances remain running. Note: unlike Azure where a deallocated VM 
  loses its public IP, AWS Elastic IP persists through stop/start — IP 
  was unchanged on restart, no downstream DNS/config updates needed.
---
*Part of an ongoing AWS + Azure incident simulation series — see [repo README] for context.*
