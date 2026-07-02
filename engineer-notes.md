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