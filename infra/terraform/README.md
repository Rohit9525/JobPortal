# Terraform EC2 Provisioning for CareerBridge

This Terraform module creates:

- 1 EC2 instance (Ubuntu 22.04)
- 1 security group with app ports
- Optional key pair creation from provided public key
- Docker + Docker Compose plugin via `user_data`

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured (`aws configure`)
- IAM permissions for EC2, VPC, Security Group, Key Pair

## Files

- `providers.tf`
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `terraform.tfvars.example`

## Usage

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform plan
terraform apply -auto-approve
```

## Important Variables

- `aws_region`: deployment region
- `instance_type`: default `t3.large`
- `allowed_cidr`: CIDR allowed for inbound traffic
- `key_pair_name`: key pair name
- `public_key`: optional SSH public key string

## Outputs

- `instance_id`
- `public_ip`
- `public_dns`
- `security_group_id`
- `ssh_user`

## Connect to EC2

```bash
ssh -i /path/to/private-key.pem ubuntu@<public_ip>
```

## Next step after provisioning

1. Clone repo on instance: `git clone https://github.com/Rohit9525/JobPortal.git`
2. Copy env file: `cp deploy/.env.aws.example deploy/.env.aws`
3. Add GitHub Actions secrets from `deploy/GITHUB_SECRETS.md`
4. Push to `main` to trigger CI/CD deploy
