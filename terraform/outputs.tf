output "my-app-id" {
  value = aws_instance.my_app.id  
}

output "my-app-public-ip" {
  value = aws_instance.my_app.public_ip  
}