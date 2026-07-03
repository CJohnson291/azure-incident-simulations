output "public_ip_address" {
  description = "Public IP of the Windows VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "rdp_command" {
  description = "RDP connection details"
  value       = "Connect via RDP to: ${azurerm_public_ip.pip.ip_address}:3389 with username: ${var.admin_username}"
}

output "vm_name" {
  description = "VM name for use in Run Commands"
  value       = azurerm_windows_virtual_machine.app1.name
}

output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.rg.name
}