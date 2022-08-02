ANSIBLE_HOST_KEY_CHECKING=False 
cd ../ansible 
rm hosts.txt || true
echo ubuntu ansible_host=${ip} ansible_user=ubuntu ansible_ssh_private_key_file=${key} >> hosts.txt
ansible-playbook -i hosts.txt main.yml