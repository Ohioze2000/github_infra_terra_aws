resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = var.vpc_id

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
  count          = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.app-tg.arn
  target_id        = var.instance_ids[count.index]
  port             = 80
} 

# Create ALB
resource "aws_lb" "app-alb" {
  name               = "${var.env_prefix}-App-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets_id            = var.subnet_id[*].id

  tags = {
    Name = "${var.env_prefix}-App-ALB"
  }
}

# Create Target Group and Listener
resource "aws_lb_target_group" "app-tg" {
  name     = "${var.env_prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

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
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }

  tags = {
    Name = "${var.env_prefix}-http-listener"
  }
}