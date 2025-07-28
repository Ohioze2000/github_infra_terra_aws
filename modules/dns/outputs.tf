output "website_url" {
  value = aws_route53_record.www.fqdn
}

output "root_url" {
    value = aws_route53_record.root.fqdn
}
output "route53_record_name" {
  value = aws_route53_record.www.fqdn
}

output "name_servers" {
  value       = aws_route53_zone.primary.name_servers
  description = "Use these NS records in your domain registrar's dashboard"
}

#output "route53-certval" {
    #value = aws_route53_record.cert_validation
#}

#output "validated_certificate_arn" { # Using a clearer name for the output
#  description = "The ARN of the validated ACM certificate."
#  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
#}

output "zone_id" {
  description = "The ID of the Route 53 Hosted Zone created by this module."
  value       = aws_route53_zone.primary.zone_id
}

output "zone_name" {
  description = "The name of the Route 53 Hosted Zone created by this module."
  value       = aws_route53_zone.primary.name
}

#output "validation_record_fqdns" {
#  description = "The FQDNs of the DNS records created for ACM certificate validation."
#  value       = [for record_key, record_value in aws_route53_record.cert_validation : record_value.fqdn]
#}