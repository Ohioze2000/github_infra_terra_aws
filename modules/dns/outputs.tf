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

output "route53-certval" {
    value = aws_route53_record.cert_validation
}

output "validated_certificate_arn" { # Using a clearer name for the output
  description = "The ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}