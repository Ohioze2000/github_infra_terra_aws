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
  security_groups    = [module.my-security.security_group.id]
  subnets            = module.my-server.subnet-2[*].id

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
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-tg.arn
  }

  tags = {
    Name = "${var.env_prefix}-http-listener"
  }
}