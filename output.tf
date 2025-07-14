/*output "public_ip"{
	value = [for instance in aws_instance.my-server : instance.public_ip]
}*/

output "alb_dns" {
  value = aws_lb.app-alb.dns_name
}

output "certificate_arn" {
  description = "Issued ACM certificate ARN"
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "cloudwatch_alarms_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.cloudwatch_alarms_topic.arn
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = aws_instance.my-server[*].id
}

output "website_url" {
  value = "https://${var.DOMAIN_NAME}"
}

output "route53_record_name" {
  value = aws_route53_record.www.fqdn
}

output "name_servers" {
  value       = aws_route53_zone.primary.name_servers
  description = "Use these NS records in your domain registrar's dashboard"
}