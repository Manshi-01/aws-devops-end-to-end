#!/bin/bash
sudo apt update -y
sudo apt install -y python3-pip git
cd /home/ubuntu
sudo rm -rf aws-devops-end-to-end
git clone https://github.com/Manshi-01/aws-devops-end-to-end.git
cd aws-devops-end-to-end/backend
chmod +x run_backend.sh
nohup bash run_backend.sh > backend.log 2>&1 &
