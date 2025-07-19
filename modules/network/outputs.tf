output "subnet" {
    value = aws_subnet.my-private-subnet-1
    
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = aws_instance.my-server[*].id
}
