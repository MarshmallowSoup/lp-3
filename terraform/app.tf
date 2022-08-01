provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "my_app" {
    ami                    = "ami-052efd3df9dad4825"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my_app_SG.id]
    key_name               = "my-key"
    
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
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["93.170.25.141/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    
}

 resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl",{
  ip = aws_instance.my_app.public_ip
 })
  filename = "../ansible/inventory"
}