## AWS vs Azure Quick Reference

### Core Services
| Category | AWS | Azure |
|----------|-----|-------|
| Virtual Machine | EC2 Instance | Virtual Machine |
| VM Image | AMI | Marketplace Image |
| Managed Disk | EBS Volume | Managed Disk |
| Object Storage | S3 | Blob Storage |
| NoSQL / Key-Value | DynamoDB | Cosmos DB / Table Storage |
| Relational DB | RDS | Azure SQL |
| Serverless Functions | Lambda | Azure Functions |
| Container Registry | ECR | ACR (Azure Container Registry) |
| Kubernetes | EKS | AKS |

### Networking
| Category | AWS | Azure |
|----------|-----|-------|
| Virtual Network | VPC | VNet |
| Subnet | Subnet | Subnet |
| Firewall Rules | Security Group | NSG |
| Public IP | Elastic IP | Public IP Address |
| Load Balancer | ALB / NLB | Azure Load Balancer / App Gateway |
| DNS | Route 53 | Azure DNS |
| CDN | CloudFront | Azure CDN / Front Door |
| VPN | AWS VPN Gateway | Azure VPN Gateway |
| Private Connectivity | Direct Connect | ExpressRoute |
| Hub & Spoke | Transit Gateway | VNet Peering + Azure Firewall |

### Identity & Security
| Category | AWS | Azure |
|----------|-----|-------|
| Identity & Access | IAM | Entra ID (Azure AD) |
| VM Identity | IAM Role | Managed Identity |
| Role Assignment | IAM Policy | RBAC Role Assignment |
| Secrets Management | Secrets Manager | Key Vault |
| Certificate Management | ACM | Key Vault Certificates |
| Just-in-Time Access | AWS IAM Identity Center | Azure PIM |
| Security Posture | Security Hub | Microsoft Defender for Cloud |
| DDoS Protection | AWS Shield | Azure DDoS Protection |

### Monitoring & Operations
| Category | AWS | Azure |
|----------|-----|-------|
| Audit Logging | CloudTrail | Activity Log |
| Metrics & Monitoring | CloudWatch | Azure Monitor |
| Alerts | CloudWatch Alarms | Azure Monitor Alerts |
| Log Analytics | CloudWatch Logs | Log Analytics Workspace |
| Query Language | CloudWatch Insights | KQL |
| Dashboards | CloudWatch Dashboards | Azure Workbooks / Grafana |
| Policy Enforcement | AWS Config | Azure Policy |

### DevOps & Automation
| Category | AWS | Azure |
|----------|-----|-------|
| CI/CD Pipelines | CodePipeline | Azure DevOps / GitHub Actions |
| Infrastructure as Code | CloudFormation | ARM / Bicep |
| IaC (third party) | Terraform | Terraform |
| Remote VM Commands | SSM Run Command | Run Command |
| Interactive Shell | SSM Session Manager | Azure Bastion / Serial Console |
| Jump Server | EC2 Bastion Host | Azure Bastion |

### Cost & Governance
| Category | AWS | Azure |
|----------|-----|-------|
| Cost Management | Cost Explorer | Cost Management + Billing |
| Budget Alerts | AWS Budgets | Azure Budgets |
| Resource Tagging | Tags | Tags |
| Resource Groups | No direct equivalent | Resource Groups |
| IaC State (remote) | S3 + DynamoDB | Azure Blob Storage |

### CLI Quick Reference
| Action | AWS CLI | Azure CLI |
|--------|---------|-----------|
| List instances | `aws ec2 describe-instances` | `az vm list` |
| Start instance | `aws ec2 start-instances --instance-ids i-xxx` | `az vm start` |
| Stop instance | `aws ec2 stop-instances --instance-ids i-xxx` | `az vm deallocate` |
| Run command | `aws ssm send-command` | `az vm run-command invoke` |
| List SG rules | `aws ec2 describe-security-groups` | `az network nsg rule list` |
| Add inbound rule | `aws ec2 authorize-security-group-ingress` | `az network nsg rule create` |
| Remove inbound rule | `aws ec2 revoke-security-group-ingress` | `az network nsg rule delete` |
| Check public IP | `aws ec2 describe-addresses` | `az network public-ip show` |