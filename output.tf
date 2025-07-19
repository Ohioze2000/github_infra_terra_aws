#
/*output "public_ip"{
	value = [for instance in aws_instance.my-server : instance.public_ip]
}*/ 
#
output "alb_dns" {
  value = module.myapp-alb.alb_dns
}

output "cloudwatch_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = module.myapp-monitoring.cloudwatch_alarms_topic_arn
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = aws_instance.my-server[*].id
}

output "website_url" {
  value = module.myapp-dns.website_url
}

output "route53_record_name" {
  value = module.myapp-dns.root_url
}

output "name_servers" {
  value       = module.myapp-dns.name_servers.zone_id
  description = "Use these NS records in your domain registrar's dashboard"
}