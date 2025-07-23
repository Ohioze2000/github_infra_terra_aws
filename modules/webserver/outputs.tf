output "instances" {
    value = aws_instance.my-server
}

output "ec2-sgroup" {
    value = aws_security_group.ec2-sg
}