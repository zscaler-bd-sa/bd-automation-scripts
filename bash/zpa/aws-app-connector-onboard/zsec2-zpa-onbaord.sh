#!/usr/bin/bash
sudo /etc/yum.repos.d/zscaler.repo -R
sudo cat > /etc/yum.repos.d/zscaler.repo <<-EOT
[zscaler]
name=Zscaler Private Access Repository
baseurl=https://yum.private.zscaler.com/yum/el7
enabled=1
gpgcheck=1
gpgkey=https://yum.private.zscaler.com/gpg
EOT

REGION=$(curl http://169.254.169.254/latest/meta-data/placement/region)
URL="http://169.254.169.254/latest/meta-data/network/interfaces/macs/"
MAC=$(curl $URL)
URL=$URL$MAC"vpc-id/"
VPC=$(curl $URL)
key="ZSDEMO"

sudo yum install zpa-connector -y
sudo yum update -y
sudo sleep 60
sudo systemctl stop zpa-connector
sudo touch /opt/zscaler/var/provision_key
sudo chmod 644 /opt/zscaler/var/provision_key
aws ssm get-parameter --name $key --query Parameter.Value --with-decryption --region $REGION | tr -d '"' > /opt/zscaler/var/provision_key
sudo systemctl start zpa-connector