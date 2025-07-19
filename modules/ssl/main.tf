# Create ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  
  validation_method = "DNS"

  subject_alternative_names = ["www.${var.domain_name}"]

  tags = {
    Name = "SSL certificate for ${var.domain_name}"
  }
}

# Validate Certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

}