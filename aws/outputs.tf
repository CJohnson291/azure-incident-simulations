output "public_ip" {
  description = "Public IP of App 1 EC2 instance"
  value       = aws_eip.app1.public_ip
}

output "app_url" {
  description = "URL to check App 1 status page"
  value       = "http://${aws_eip.app1.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to App 1"
  value       = "ssh -i ~/.ssh/id_rsa_aws ubuntu@${aws_eip.app1.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID - used in AWS CLI commands"
  value       = aws_instance.app1.id
}

output "security_group_id" {
  description = "Security Group ID - used in AWS CLI commands"
  value       = aws_security_group.app1.id
}