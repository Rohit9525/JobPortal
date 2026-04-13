# GitHub Actions Secrets (exact names)

Add these in GitHub repository settings:

Settings -> Secrets and variables -> Actions -> New repository secret

## Required

- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
- AWS_EC2_HOST
- AWS_EC2_USER
- AWS_EC2_SSH_KEY

## Required for runtime config written on EC2

- JWT_SECRET
- MYSQL_ROOT_PASSWORD
- MYSQL_USERNAME
- MYSQL_PASSWORD
- CLOUDINARY_CLOUD_NAME
- CLOUDINARY_API_KEY
- CLOUDINARY_API_SECRET
- MAIL_USERNAME
- MAIL_PASSWORD

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

## Runtime secret guidance

- JWT_SECRET: Strong random signing key, at least 64 characters
- MYSQL_ROOT_PASSWORD: MySQL root password used by the container
- MYSQL_USERNAME: Application database username
- MYSQL_PASSWORD: Application database password
- CLOUDINARY_CLOUD_NAME: Cloudinary account cloud name
- CLOUDINARY_API_KEY: Cloudinary API key
- CLOUDINARY_API_SECRET: Cloudinary API secret
- MAIL_USERNAME: Gmail address used for SMTP
- MAIL_PASSWORD: Gmail App Password, not the account password

## EC2 deploy behavior

The GitHub Actions deploy job writes the runtime `.env` file on the EC2 host before running Docker Compose.
If you deploy manually, create the same `.env` file in the repository root or pass an equivalent env file with `docker compose --env-file`.
