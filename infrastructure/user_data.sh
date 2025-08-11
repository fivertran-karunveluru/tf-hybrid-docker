#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm
sudo useradd -m -s "$(which bash)" -G wheel fivetran
sudo usermod -aG docker fivetran
sudo -u fivetran TOKEN="${agent_token}" RUNTIME=docker bash -c "$(curl -sL https://raw.githubusercontent.com/fivetran/hybrid_deployment/main/install.sh)"
