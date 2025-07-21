output "subnet" {
    value = aws_subnet.my-private-subnet-1
    
}

output "subnet-2" {
    value = aws_subnet.my-public-subnet-1
    
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = module.my-server.instances[*].id
}
