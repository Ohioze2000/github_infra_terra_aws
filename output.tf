#
/*output "public_ip"{
	value = [for instance in aws_instance.my-server : instance.public_ip]
}*/ 
#
output "alb_dns" {
  value = module.my-alb.alb_dns
}

output "cloudwatch_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = module.my-monitoring.cloudwatch_alarms_topic_arn
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = module.my-server.instances[*].id
}

output "website_url" {
  value = module.my-dns.website_url
}

output "route53_record_name" {
  value = module.my-dns.root_url
}

output "name_servers" {
  value       = module.my-dns.name_servers.zone_id
  description = "Use these NS records in your domain registrar's dashboard"
}