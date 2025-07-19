output "website_url" {
  value = aws_route53_record.www
}

output "root_url" {
    value = aws_route53_record.root
}

output "route53_record_name" {
  value = aws_route53_record.www.fqdn
}

output "name_servers" {
  value       = aws_route53_zone.primary.zone_id
  description = "Use these NS records in your domain registrar's dashboard"
}