output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.careerbridge_ec2.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.careerbridge_ec2.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.careerbridge_ec2.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.careerbridge_sg.id
}

output "ssh_user" {
  description = "Default SSH username for Ubuntu AMI"
  value       = "ubuntu"
}
