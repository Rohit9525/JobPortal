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
  default     = ""
}

variable "public_key" {
  description = "Optional SSH public key content (leave empty to use existing key pair by name)"
  type        = string
  default     = ""
}

variable "project_repo_url" {
  description = "Git repository URL to deploy on the EC2 instance"
  type        = string
  default     = "https://github.com/Rohit9525/JobPortal.git"
}

variable "project_dir" {
  description = "Target directory on EC2 where the project will be cloned"
  type        = string
  default     = "/home/ubuntu/careerbridge"
}

variable "jwt_secret" {
  description = "JWT secret used by services"
  type        = string
  sensitive   = true
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "mysql_username" {
  description = "MySQL application username"
  type        = string
}

variable "mysql_password" {
  description = "MySQL application password"
  type        = string
  sensitive   = true
}

variable "cloudinary_cloud_name" {
  description = "Cloudinary cloud name"
  type        = string
}

variable "cloudinary_api_key" {
  description = "Cloudinary API key"
  type        = string
  sensitive   = true
}

variable "cloudinary_api_secret" {
  description = "Cloudinary API secret"
  type        = string
  sensitive   = true
}

variable "mail_username" {
  description = "SMTP username"
  type        = string
}

variable "mail_password" {
  description = "SMTP password or app key"
  type        = string
  sensitive   = true
}
