variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 40
}

variable "allowed_cidr" {
  description = "CIDR allowed to access service ports"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair_name" {
  description = "Existing key pair name, or name to create if public_key is provided"
  type        = string
}

variable "public_key" {
  description = "Optional SSH public key content (leave empty to use existing key pair by name)"
  type        = string
  default     = ""
}
