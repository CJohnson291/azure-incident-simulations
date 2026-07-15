#!/bin/bash

az vm run-command invoke \
  --resource-group rg-incidentsim-windows \
  --name vm-win-app1 \
  --command-id RunPowerShellScript \
  --scripts "
# Set account lockout policy - lock after 3 failed attempts
net accounts /lockoutthreshold:3 /lockoutduration:30 /lockoutwindow:30

# Simulate failed login attempts to lock the account
\$username = 'azureadmin'
\$wrongPassword = ConvertTo-SecureString 'WrongPassword123!' -AsPlainText -Force
\$credential = New-Object System.Management.Automation.PSCredential(\$username, \$wrongPassword)

# Attempt failed logins to trigger lockout
1..4 | ForEach-Object {
    try {
        \$null = [System.DirectoryServices.AccountManagement.PrincipalContext]::new('Machine')
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        \$ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Machine')
        \$ctx.ValidateCredentials(\$username, 'WrongPassword123!')
    } catch {}
}
Write-Host 'Lockout policy set and failed attempts triggered'
" \
  --output none
