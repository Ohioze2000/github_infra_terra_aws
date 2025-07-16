#
data "aws_availability_zones" "available" {
  state = "available"
}

# IMPORTANT: Filter the list of available AZs to only the first 'az_count'--
locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true

    tags ={
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "my-public-subnet-1" {
    count             = var.az_count
    cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
    vpc_id = aws_vpc.my-vpc.id
    availability_zone   = local.selected_azs[count.index] # Use the filtered list of AZs
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.env_prefix}-pub-subnet-${count.index + 1}"
    }
}

resource "aws_subnet" "my-private-subnet-1" {
    count             = var.az_count # Use az_count here too
    cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.az_count)
    vpc_id = aws_vpc.my-vpc.id
    availability_zone   = local.selected_azs[count.index] # Use the filtered list of AZs

    tags = {
        Name = "${var.env_prefix}-priv-subnet-${count.index + 1}"
    }
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id

    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table" "my-rtb" {
    vpc_id = aws_vpc.my-vpc.id
        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.my-igw.id
        }
    
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_route_table_association" "my-rtb-sub-ass" {
    count          = 1
    subnet_id = aws_subnet.my-public-subnet-1[count.index].id
    route_table_id = aws_route_table.my-rtb.id
}

# Elastic IP for NAT Gateway
    resource "aws_eip" "nat" {
    count = 1
}

# NAT Gateway
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.my-public-subnet-1[0].id
  depends_on    = [aws_internet_gateway.my-igw]

  tags = {
    Name = "${var.env_prefix}-nat-gw"
  }
}

# Private Route Table
resource "aws_route_table" "my-private-rtb" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat.id
  }

  tags = {
    Name = "${var.env_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = aws_subnet.my-private-subnet-1[count.index].id
  route_table_id = aws_route_table.my-private-rtb.id
}

# Security Group for EC2
resource "aws_security_group" "ec2-sg" {
    name = "ec2-sg"
    vpc_id = aws_vpc.my-vpc.id
    description = "Allow ALB to reach EC2"
        ingress {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            security_groups = [aws_security_group.alb-sg.id]
        }

        egress {
            from_port = 0
            to_port = 0
            protocol = -1
            cidr_blocks = ["0.0.0.0/0"]
            prefix_list_ids = []
        }

    tags = {
        Name = "${var.env_prefix}-ec2_sg"
    }    
}

# Security Group for ALB
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     Name = "${var.env_prefix}-alb-sg"
  }
}

# Register EC2 in Target Group
resource "aws_lb_target_group_attachment" "web_attach" {
  count          = length(aws_instance.my-server)
  target_group_arn = aws_lb_target_group.app-tg.arn
  target_id        = aws_instance.my-server[count.index].id
  port             = 80
} 

# Create ALB
resource "aws_lb" "app-alb" {
  name               = "${var.env_prefix}-App-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = aws_subnet.my-public-subnet-1[*].id

  tags = {
    Name = "${var.env_prefix}-App-ALB"
  }
}

# Create Target Group and Listener
resource "aws_lb_target_group" "app-tg" {
  name     = "${var.env_prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.env_prefix}-App-TG"
  }
}

# HTTPS Listener
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app-alb.arn  # Associate with your Load Balancer
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }

  tags = {
    Name = "${var.env_prefix}-http-listener"
  }
}

# Create Hosted Zone
resource "aws_route53_zone" "primary" {
  name = "slimecloud.online"
}

# Route 53 Hosted Zone
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app-alb.dns_name       # or aws_instance.web.public_dns
    zone_id                = aws_lb.app-alb.zone_id        # ALB zone ID
    evaluate_target_health = true
  }
}

# Alias record for the www subdomain
resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}" # The www subdomain
  type    = "A"
  alias {
    name                   = aws_lb.app-alb.dns_name
    zone_id                = aws_lb.app-alb.zone_id
    evaluate_target_health = true
  }
  # This record depends on the ACM certificate being validated,
  # as well as the ALB being available and its listeners configured.
  depends_on = [
    aws_acm_certificate_validation.cert_validation,
    aws_lb_listener.https,
    aws_lb_listener.http_redirect
  ]
}

# Add DNS Validation Record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Create ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = aws_route53_zone.primary.name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "SSL certificate for ${var.domain_name}"
  }
}

# Validate Certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  depends_on = [aws_route53_record.cert_validation]
}

# To get NS records
/*data "aws_route53_zone" "selected" {
  zone_id = var.route53_zone_id
}*/

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = var.public_key_location
}

# IAM Role for SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.env_prefix}-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the AWS managed policy for CloudWatch Agent communication
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.env_prefix}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name = "${var.env_prefix}-ec2-ssm-profile"
  }
}

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images-testing/hvm-ssd-gp3/ubuntu-plucky-daily-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my-server" {
# The count here *must* match the count of your subnets
    count = var.az_count
    
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    associate_public_ip_address = false
    key_name = aws_key_pair.ssh-key.key_name
    security_groups = [aws_security_group.ec2-sg.id]
    subnet_id     = aws_subnet.my-private-subnet-1[count.index].id
    availability_zone           = local.selected_azs[count.index] # Use the filtered list of AZs
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

    user_data = file("entry-script.sh")

    tags = {
      name = "${var.env_prefix}-webserver01-${count.index + 1}"
       SSM  = "Enabled" 
    }   
}