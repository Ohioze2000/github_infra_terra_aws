#SNS Topic for CloudWatch Alarms ---
resource "aws_sns_topic" "cloudwatch_alarms_topic" {
  name = "${var.env_prefix}-cloudwatch-alarms"
  display_name = "${var.env_prefix} CloudWatch Alarms"

  tags = {
    Name = "${var.env_prefix}-cloudwatch-alarms"
  }
}

#CloudWatch Alarm for Average CPU Utilization across all web servers ----
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.env_prefix}-High-CPU-Utilization-${count.index + 1}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 80 # Trigger if CPU is >= 80%
  alarm_description   = "Alarm when average CPU utilization is too high across web servers"

  #Apply this alarm to instances that are part of your web server group
  #dimensions = {
    #AutoScalingGroupName = "your-autoscaling-group-name" # If you use an ASG
    # Or, if not using ASG, you might target specific instances or use a common tag
    # For now, let's assume you'll target specific instances or groups in the console/later
    # Or, you can create one alarm per instance if 'count' is used:
    # InstanceId = aws_instance.my-server[0].id # For a single instance
  #}

  # If you want one alarm per instance (using count):
    count = length(var.instance_ids)
  # alarm_name = "${var.env_prefix}-High-CPU-Utilization-${count.index + 1}"
   dimensions = {
    InstanceId = var.instance_ids[count.index]
   }

  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms_topic.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarms_topic.arn]

  tags = {
    Name = "${var.env_prefix}-High-CPU-Alarm-${count.index + 1}"
  }
}

#Subscribe an email address to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarms_topic.arn
  protocol  = "email"
  endpoint  = "ohiozeberyl2000@gmail.com" # <--- IMPORTANT: Change this to your email address

  # You will receive a confirmation email. You must click the link in the email to confirm the subscription.
}
