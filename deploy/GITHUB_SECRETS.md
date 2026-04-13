# GitHub Actions Secrets (exact names)

Add these in GitHub repository settings:

Settings -> Secrets and variables -> Actions -> New repository secret

## Required

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
- AWS_EC2_HOST
- AWS_EC2_USER
- AWS_EC2_SSH_KEY

## Optional

- AWS_EC2_PORT (default 22)
- AWS_APP_DIR (default $HOME/careerbridge)

## Value format guidance

- DOCKERHUB_USERNAME: Docker Hub account username
- DOCKERHUB_TOKEN: Docker Hub access token (not password)
- AWS_EC2_HOST: Public IPv4 or DNS of EC2
- AWS_EC2_USER: ubuntu (Ubuntu AMI) or ec2-user (Amazon Linux)
- AWS_EC2_SSH_KEY: Full private key content including BEGIN/END lines
- AWS_EC2_PORT: Numeric SSH port, e.g. 22
- AWS_APP_DIR: Absolute path on EC2, e.g. /home/ubuntu/careerbridge

## Additional server file required

On EC2, create this file before first deploy:

- deploy/.env.aws

You can copy from template:

cp deploy/.env.aws.example deploy/.env.aws

Then edit values for production credentials.
