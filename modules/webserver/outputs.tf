output "instance_ids" {
    value = aws_instance.my-server[*].id
    description = "List of IDs for the created EC2 instances."
}

output "ec2_security_group_id" { # Renamed for clarity, outputs ID only
  description = "The ID of the EC2 security group."
  value       = aws_security_group.ec2-sg.id
}

output "ec2_security_group_name" { # Added for completeness
  description = "The name of the EC2 security group."
  value       = aws_security_group.ec2-sg.name
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