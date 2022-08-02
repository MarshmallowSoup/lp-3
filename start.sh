#!/usr/bin/bash
cd terraform 
terraform apply -auto-approve
cd ..
chmod 400 ~/.ssh/my-key.pem
cd ansible 
sleep 60
ansible all -i inventory -m ping 
ansible-playbook -i inventory main.yml