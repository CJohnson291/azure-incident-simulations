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
  description = "Admin username for the Linux VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Your SSH public key (contents of e.g. ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the VM (use your own public IP /32 for security)"
  type        = string
}

variable "vm_size" {
  description = "VM size - B1s is the cheapest general purpose option"
  type        = string
  default     = "Standard_B2s_v2"
}
