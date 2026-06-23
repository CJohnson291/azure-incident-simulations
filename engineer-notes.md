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