variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "prefix" {
  description = "Naming prefix for all resources"
  type        = string
  default     = "incidentsim"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (use your own public IP /32)"
  type        = string
}

variable "ssh_public_key" {
  description = "Your SSH public key (contents of ~/.ssh/id_rsa.pub or equivalent)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type - t2.micro is free tier eligible"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for eu-west-2 (London)"
  type        = string
  default     = "ami-0505148b3591e4c07"
}