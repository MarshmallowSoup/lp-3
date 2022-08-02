provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "latest_ubuntu"{
    owners      = [ "099720109477" ]
    most_recent = true
    filter{
        name  = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}


resource "aws_instance" "my_app" {
    ami                    =  data.aws_ami.latest_ubuntu.id
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my_app_SG.id]
    key_name               = "my-key"
    depends_on = [aws_security_group.my_app_SG]
 
    lifecycle {
       create_before_destroy = true
    }

    provisioner "file" {
       connection {
        host         = aws_instance.my_app.public_dns
        user         = "ubuntu"
        private_key  = file(var.key)
    }
      source = "../ansible"
      destination = "/home/ubuntu"
    }

    provisioner "remote-exec" {
      connection {
        host         = aws_instance.my_app.public_dns
        user         = "ubuntu"
        private_key  = file(var.key)
    }

      inline = ["sudo apt update",
      "sudo apt install -y ansible",
      "ansible-playbook ansible/main.yml"
      ]
    }

   
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}


resource "aws_security_group" "my_app_SG"{
    name         = "my_app_SG"     
    description  = "my_app_SecurityGroup"     

    dynamic "ingress"{
        for_each = ["80", "443", "5000"]
        content{
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    
}

 /*resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl",{
  ip      = aws_instance.my_app.public_ip, 
  path    = var.key
 })
  filename = "../ansible/inventory"
}*/

/*resource "null_resource" "wait2connect" {
 

   provisioner "local-exec" {
      command = templatefile ("startScript.sh.tpl",{
      ip = aws_instance.my_app.public_ip,
      key = var.key
      })
    }
}*/


