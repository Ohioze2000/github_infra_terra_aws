# Create Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name

  tags = {
    Name        = "${var.env_prefix}-hosted-zone"
    ManagedBy   = "Terraform"
  }
}

# Route 53 Hosted Zone
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name        # or aws_instance.web.public_dns
    zone_id                = var.alb_zone_id        # ALB zone ID
    evaluate_target_health = true
  }
}

# Alias record for the www subdomain
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}" # The www subdomain
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
  
}

locals {
  # This map prepares the exact data needed for each Route53 record.
  # The keys (dvo.domain_name) are derived from the ACM certificate's requested domains,
  # which allows Terraform to determine them at plan time.
  # The values are maps containing name, type, and record.
  cert_validation_records = {
    for dvo in var.acm_domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
    }
  }
}

 # Add DNS Validation Record
 resource "aws_route53_record" "cert_validation" {
#  for_each = local.validation_domains # Iterate over the known domain names
  for_each = local.cert_validation_records # Iterate over the map of prepared record data

   zone_id = aws_route53_zone.primary.zone_id

  # Find the specific validation details for the current domain name (each.key)
  # This 'record_details' will be a single object containing resource_record_name, type, and value

  # Use try() for robustness in case record_details somehow isn't found
#  name    = try(self.record_details.resource_record_name, null)
#  type    = try(self.record_details.resource_record_type, null)
  # Access the values directly from the 'each.value' map
  name    = each.value.name
  type    = each.value.type
   ttl     = 60
#  records = [try(self.record_details.resource_record_value, null)]
  records = [each.value.record]
 }