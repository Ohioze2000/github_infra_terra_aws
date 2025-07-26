output "instances" {
    value = aws_instance.my-server
}

output "ec2-sgroup" {
    value = aws_security_group.ec2-sg
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances created by this module."
  value       = aws_instance.my-server[*].id # Or whatever your instance resource is named
}

output "private_instance_private_ips" {
  description = "Private IPs of the private EC2 instances created by this module."
  value       = aws_instance.my-server[*].private_ip # Adjust 'my-server' if your resource name differs
}

#output "instance_ids_list" { # A list of string IDs
#  description = "List of IDs for the instances created in this module."
#  value       = aws_instance.my-server.*.id
#}