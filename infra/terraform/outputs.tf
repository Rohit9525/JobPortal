output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.careerbridge_ec2.id
}

output "elastic_ip" {
  description = "EC2 static Elastic IP address"
  value       = aws_eip.careerbridge_eip.public_ip
}

output "public_ip" {
  description = "EC2 public IP (deprecated: use elastic_ip for static address)"
  value       = aws_instance.careerbridge_ec2.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.careerbridge_sg.id
}

output "ssh_user" {
  description = "Default SSH username for Ubuntu AMI"
  value       = "ubuntu"
}
