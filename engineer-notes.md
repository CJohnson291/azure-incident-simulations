## nginx
sudo systemctl status nginx        # check if service is running
sudo systemctl start/stop/restart nginx   # manage the service
sudo tail -20 /var/log/nginx/error.log    # check error logs

## Linux permissions
ls -la /path                       # check permissions on files/dirs
sudo chmod -R 755 /path            # restore standard web directory perms
sudo chown -R www-data:www-data /path  # restore nginx ownership

## Azure CLI
az vm run-command invoke ...       # run command on VM without SSH
az network nsg rule show ...       # check NSG rule access
az vm list-usage --location ...    # check quota availability

## Push to GIT
git add .                          # add changes to Git
git commit -m "insert subject"     # add a commit subject message 
git push origin main               # push to git

## DNS / Name Resolution
nslookup github.com          # test DNS resolution from VM
ping -c 4 8.8.8.8            # test IP connectivity (not DNS)
# If ping works but nslookup fails = DNS issue, not network issue
# Check VNet DNS settings first — overrides VM-level config
# Azure default DNS: 168.63.129.16

# List all subscriptions you have access to
az account list --output table

# Switch subscription — by name
az account set --subscription "My Subscription Name"

# Linux VM commands
# Disk
df -h                              # disk usage across all filesystems
ls -lt /var/log/ | head -20        # log directory sorted newest first - spotted the culprit
ls -lh /path/to/file               # check specific file size
rm /path/to/file && df -h          # delete file and confirm space recovered
du -sh /var/log/*                  # size of each item in a directory
# Processes
ps aux --sort=-%cpu | head -20     # top processes by CPU usage
# Services
systemctl list-units --state=failed  # any failed servicesYes 

sudo ss -tlnp | grep nginx    # check what port nginx is actually listening on
sudo ss -tlnp                 # check all listening ports and services


## Terraform State Lock
# If terraform apply fails with "state locked" error:
terraform plan                          # get the lock ID from the error output

# For remote state (S3, Azure Blob):
terraform force-unlock <LOCK_ID>        # force unlock using the ID

# For local state:
rm .terraform.tfstate.lock.info         # delete the lock file directly

# Then retry:
terraform apply

# If force-unlock and deleting lock file both fail:
terraform apply -lock=false    # bypass locking entirely
# Only safe for solo/local environments - never use in shared/production state


az network nic show \
  --resource-group rg-incidentsim \
  --name nic-incidentsim-app1 \
  --query "networkSecurityGroup.id" \
  --output tsv

  az network nic update \
  --resource-group rg-incidentsim \
  --name nic-incidentsim-app1 \
  --network-security-group nsg-incidentsim-app1

## Powershell

  # Check RDP service status
Get-Service -Name TermService | Select-Object Name, Status, StartType

# Restore and start RDP service
Set-Service -Name TermService -StartupType Automatic
Start-Service -Name TermService

# Check all stopped services
Get-Service | Where-Object {$_.Status -eq "Stopped"}

# Check if port 3389 is listening
netstat -an | findstr 3389

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "netstat -an | findstr 3389"


## RDP error codes
0x204 — connection refused, service not running
Timeout — network block (NSG, firewall)
0x907 — VM not ready/booting
Credentials error — wrong username/password

# Check Windows Firewall RDP rule
Get-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' | Select-Object DisplayName, Enabled, Direction

# Enable RDP firewall rule
Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -Enabled True

# Check all disabled firewall rules
Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'False' -and $_.Direction -eq 'Inbound'}

# Check what's listening on port 3389
netstat -an | findstr 3389


# Check ip
curl -4 ifconfig.me

# update NSG with my current IP
az network nsg rule update \
  --resource-group rg-incidentsim-windows \
  --nsg-name nsg-incidentsim-windows-app1 \
  --name Allow-RDP \
  --source-address-prefixes $(curl -4 -s ifconfig.me)/32

  # Check cipher state
$basePath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers'
Get-ItemProperty -Path "$basePath\RC4 128/128"

# Disable weak cipher
Set-ItemProperty -Path "$basePath\RC4 128/128" -Name 'Enabled' -Value 0 -Type DWORD -Force

# Enable strong cipher
Set-ItemProperty -Path "$basePath\AES 256/256" -Name 'Enabled' -Value 1 -Type DWORD -Force