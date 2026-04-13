data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*",
      "ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "careerbridge_sg" {
  name_prefix = "careerbridge-sg-"
  description = "Security group for CareerBridge EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "API Gateway"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Auth service"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Job service"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Application service"
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "File service"
    from_port   = 8084
    to_port     = 8084
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Notification service"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Admin service"
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Eureka"
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Config server"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "careerbridge-sg"
    Project     = "CareerBridge"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

resource "aws_key_pair" "careerbridge_key" {
  count      = var.public_key == "" ? 0 : 1
  key_name   = var.key_pair_name
  public_key = var.public_key

  tags = {
    Name        = var.key_pair_name
    Project     = "CareerBridge"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

locals {
  effective_key_name = var.public_key != "" ? aws_key_pair.careerbridge_key[0].key_name : (var.key_pair_name != "" ? var.key_pair_name : null)
}

resource "aws_instance" "careerbridge_ec2" {
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.careerbridge_sg.id]
  key_name               = local.effective_key_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata.sh.tftpl", {
    project_repo_url       = var.project_repo_url
    project_dir            = var.project_dir
    jwt_secret             = var.jwt_secret
    mysql_root_password    = var.mysql_root_password
    mysql_username         = var.mysql_username
    mysql_password         = var.mysql_password
    cloudinary_cloud_name  = var.cloudinary_cloud_name
    cloudinary_api_key     = var.cloudinary_api_key
    cloudinary_api_secret  = var.cloudinary_api_secret
    mail_username          = var.mail_username
    mail_password          = var.mail_password
  })

  tags = {
    Name        = "careerbridge-ec2"
    Project     = "CareerBridge"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}
