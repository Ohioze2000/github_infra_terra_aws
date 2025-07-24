output "instances" {
    value = aws_instance.my-server
}

output "ec2-sgroup" {
    value = aws_security_group.ec2-sg
}

output "instance_ids" {
  description = "IDs of the private EC2 instances created by this module."
  value       = aws_instance.my-server[*].id # Or whatever your instance resource is named
}

output "instance_ids_list" { # A list of string IDs
  description = "List of IDs for the instances created in this module."
  value       = aws_instance.your_instance_resource_name.*.id
}