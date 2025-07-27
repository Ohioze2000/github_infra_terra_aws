#
/*output "public_ip"{
	value = [for instance in aws_instance.my-server : instance.public_ip]
}*/ 
#
output "alb_dns" {
  description = "The DNS name of the Application Load Balancer."
  value = module.my-alb.alb_dns_name
}

#output "certval" {
#  description = "The ARN of the validated certificate (re-exported from my-dns module)."
#  value       = module.my-dns.validated_certificate_arn
#}

output "cloudwatch_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = module.my-monitoring.cloudwatch_alarms_topic_arn
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances deployed."
  value       = module.my-server.private_instance_ids
}

#output "private_instance_ids" {
#  description = "IDs of the private EC2 instances (re-exported from my-server module)."
#  value       = module.my-server.instance_ids_list # Echoing the output from my-server
#}

output "website_url" {
  description = "The HTTPS URL of the deployed website."
  value = "https://${var.domain_name}"
}

output "route53_zone_name" {
  description = "The name of the Route 53 Hosted Zone created."
  value       = module.my-dns.zone_name # Common output for a hosted zone's name
}

#output "route53_record_name" {
#  value = module.my-dns.root_url
#}

output "name_servers" {
  description = "Use these NS records in your domain registrar's dashboard"
  value       = module.my-dns.name_servers
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.my-subnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.my-subnet.private_subnet_ids
}

output "validated_certificate_arn" {
  description = "The ARN of the validated ACM certificate."
  #value       = module.my-ssl.validated_certificate_arn # Requires DNS module to output this
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.my-vpc.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = module.my-alb.alb_arn # Assuming my-alb outputs this
}

output "alb_hosted_zone_id" {
  description = "The Hosted Zone ID of the Application Load Balancer (for Route 53 alias records)."
  value       = module.my-alb.alb_hosted_zone_id # Assuming my-alb outputs this
}

output "route53_zone_id" {
  description = "The ID of the Route 53 Hosted Zone created."
  value       = module.my-dns.zone_id # Assuming my-dns outputs this
}





#output "private_instance_ids" {
#  description = "IDs of the private EC2 instances from the my-server module"
#  value       = module.my-server.instance_ids # Accessing the output of the 'my-server' child module
#}