
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.62.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true

    tags ={
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_acm_certificate_validation" "cert_validation" {
   certificate_arn         = module.my-ssl.certificate_arn # Get ARN from SSL module
   validation_record_fqdns = module.my-dns.validation_record_fqdns # Get FQDNs from DNS module

   # Explicitly depend on the DNS records being created before attempting validation
   depends_on = [module.my-dns]
 }

module "my-subnet" {
  source = "./modules/network"
  vpc_id = aws_vpc.my-vpc.id
  env_prefix = var.env_prefix
  az_count = var.az_count
  vpc_cidr_block = var.vpc_cidr_block
}

module "my-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my-vpc.id
  #public_key_location = var.public_key_location
  az_count = var.az_count
  instance_type = var.instance_type
  #public_key_path = var.public_key_path
  public_key_content = var.public_key_content
  env_prefix = var.env_prefix
  private_subnet_ids = module.my-subnet.private_subnet_ids
  #subnet_id = module.my-subnet.subnet.id
  image_name = var.image_name
  alb_security_group_id = module.my-alb.alb_security_group_id
  #iam_instance_profile_name = module.my-iam.iam_instance_profile_name
  iam_instance_profile_name = module.ec2_ssm_role-iam.iam_instance_profile_name
}

module "ec2_ssm_role-iam" {
  source = "./modules/iam"
  env_prefix = var.env_prefix
  iam_instance_profile_name = "${var.env_prefix}-ec2-ssm-instance-profile"
}

module "my-alb" {
  source = "./modules/alb"
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.my-vpc.id
  #my_ip = var.my_ip
  #server_id = var.server_id
  subnet_ids = module.my-subnet.public_subnet_ids
  instance_ids = module.my-server.instance_ids
  #hosted_zone_id = module.my-dns.zone_id
  #domain_name    = module.my-dns.zone_name
  certificate_arn = module.my-ssl.validated_certificate_arn 
}

module "my-dns" {
  source = "./modules/dns"
  domain_name = var.domain_name
  env_prefix = var.env_prefix
  #public_subnet_ids      = module.my-subnet.public_subnet_ids
  #private_subnet_ids     = module.my-subnet.private_subnet_ids
  #hosted_zone_id = var.hosted_zone_id
  acm_domain_validation_options = module.my-ssl.domain_validation_options
  #certificate_arn               = module.my-ssl.certificate_arn
  #certificate_domain_name       = module.my-ssl.domain_name
  #alb_id = var.alb_id
  #cert_id = var.cert_id
  alb_dns_name    = module.my-alb.alb_dns_name
  alb_zone_id     = module.my-alb.alb_hosted_zone_id
}

module "my-ssl" {
  source = "./modules/ssl"
  domain_name = var.domain_name
  #validation_record_fqdns = module.my-dns.validation_record_fqdns
  #certval_id = var.certval_id
}

module "my-monitoring" {
  source = "./modules/monitoring"
  env_prefix = var.env_prefix
  #server_id = var.server_id
  instance_ids = module.my-server.private_instance_ids
}











# To get NS records
/*data "aws_route53_zone" "selected" {
  zone_id = var.route53_zone_id
}*/

