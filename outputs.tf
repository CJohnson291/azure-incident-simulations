output "public_ip_address" {
  description = "Public IP of the App 1 VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.ip_address}"
}

output "app_url" {
  description = "URL to check App 1's status page"
  value       = "http://${azurerm_public_ip.pip.ip_address}"
}
