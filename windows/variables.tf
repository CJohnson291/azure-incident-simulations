variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "West Europe"
}

variable "prefix" {
  description = "Naming prefix for all resources"
  type        = string
  default     = "incidentsim"
}

variable "admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for the Windows VM (min 12 chars, must include uppercase, lowercase, number, special char)"
  type        = string
  sensitive   = true
}

variable "allowed_rdp_cidr" {
  description = "CIDR allowed to RDP to the VM (use your own public IP /32 for security)"
  type        = string
}

variable "vm_size" {
  description = "VM size - B2s_v2 is cheapest available on this subscription"
  type        = string
  default     = "Standard_B2s_v2"
}