
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

module "my-subnet" {
  source = "./modules/network"
  vpc_id = aws_vpc.my-vpc.id
  env_prefix = var.env_prefix
  az_count = var.az_count
  vpc_cidr_block = var.vpc_cidr_block
  route_table_id = var.route_table.id
  domain_name = var.domain_name
  instance_type = var.instance_type
  my_ip = var.my_ip
  public_key_location = var.public_key_location
}

module "my-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.my-vpc.id
  public_key_location = var.public_key_location
  az_count = var.az_count
  instance_type = var.instance_type
  env_prefix = var.env_prefix
  subnet_id = module.my-subnet.subnet.id
  image_name = var.image_name
}

module "ec2_ssm_role-iam" {
  source = "./modules/iam"
  env_prefix = var.env_prefix
}

module "my-alb" {
  source = "./modules/alb"
  domain_name = var.domain_name
  public_key_location = var.public_key_location
  env_prefix = var.env_prefix
  vpc_cidr_block = var.vpc_cidr_block
  my_ip = var.my_ip
  instance_type = var.instance_type
  vpc_id = aws_vpc.my-vpc.id
}

module "my-dns" {
  source = "./modules/dns"
  domain_name = var.domain_name
  instance_type = var.instance_type
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  vpc_cidr_block = var.vpc_cidr_block
  my_ip = var.my_ip
}

module "my-security" {
  source = "./modules/security"
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  domain_name = var.domain_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  vpc_cidr_block = var.vpc_cidr_block
  vpc_id = aws_vpc.my-vpc.id
}

module "my-ssl" {
  source = "./modules/ssl"
  domain_name = var.domain_name
  vpc_cidr_block = var.vpc_cidr_block
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  instance_type = var.instance_type
  public_key_location = var.public_key_location
}

module "my-monitoring" {
  source = "./modules/monitoring"
  env_prefix = var.env_prefix
}











# To get NS records
/*data "aws_route53_zone" "selected" {
  zone_id = var.route53_zone_id
}*/

