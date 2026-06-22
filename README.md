# Azure Incident Simulation - Baseline Environment

A standalone, throwaway Azure environment ("App 1") used for incident-response
practice scenarios. Kept separate from the main landing zone portfolio.

## What this deploys

- Resource group `rg-incidentsim`
- VNet (10.50.0.0/16) + subnet (10.50.1.0/24)
- NSG allowing inbound SSH (from your IP only) and HTTP (80) from anywhere
- Public IP (Static, Basic SKU)
- Ubuntu 22.04 VM (Standard_B1s) running nginx, serving a simple
  "App 1 - Status: OK" page via cloud-init

## Cost

Standard_B1s is roughly £0.01-0.02/hour (~£7-9/month if left running 24/7).
Static Basic Public IP is a few pence/day. Destroy after each scenario to
keep costs negligible (pennies per session).

## Usage

1. Find your current public IP (e.g. `curl ifconfig.me`) and use it as
   `allowed_ssh_cidr` in `terraform.tfvars`, formatted as `x.x.x.x/32`.

2. Create a `terraform.tfvars` file (not committed) with:

   ```hcl
   ssh_public_key   = "ssh-ed25519 AAAA... your-key"
   allowed_ssh_cidr = "203.0.113.10/32"
   ```

3. Deploy:

   ```bash
   terraform init
   terraform apply
   ```

4. Confirm the baseline is healthy:

   ```bash
   curl $(terraform output -raw app_url)
   ```

   Should return the "App 1 - Status: OK" page.

5. Apply the fault-injection script provided for the scenario (without
   reading it first).

6. Investigate the "ticket" using SSH, Azure CLI, Azure Portal, etc.

7. Document your investigation and fix in an incident report.

8. Tear down:

   ```bash
   terraform destroy
   ```

## Notes

- State is kept local (no remote backend) since this environment is
  deployed and destroyed per scenario - no need for shared state.
- Re-running `terraform apply` after a fault has been injected and fixed
  will reset to the clean baseline (depending on the nature of the fault -
  some faults made outside Terraform's awareness, e.g. via SSH, may need
  a `terraform destroy` + re-apply to fully reset).
