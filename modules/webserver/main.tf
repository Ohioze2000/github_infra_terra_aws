#

# Security Group for EC2
resource "aws_security_group" "ec2-sg" {
    name = "ec2-sg"
    vpc_id = var.vpc_id
    description = "Allow ALB to reach EC2"
        ingress {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            security_groups = [var.alb_security_group_id]
            description = "Allow HTTP from ALB"
        }

        egress {
            from_port = 0
            to_port = 0
            protocol = -1
            cidr_blocks = ["0.0.0.0/0"]
            prefix_list_ids = []
            description = "Allow all outbound traffic"
        }

    tags = {
        Name = "${var.env_prefix}-ec2_sg"
    }    
}

data "aws_availability_zones" "available" {
  state = "available"
}

# IMPORTANT: Filter the list of available AZs to only the first 'az_count'--
locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = var.public_key_location
}

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = [var.image_name]
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
    #security_groups = [aws_security_group.ec2-sg.id]
    subnet_id     = var.subnet_id
    availability_zone           = local.selected_azs[count.index] # Use the filtered list of AZs
    iam_instance_profile = module.iam_profile.myapp-iam.name

    vpc_security_group_ids = [aws_security_group.ec2-sg.id]

    user_data = file("entry-script.sh")

    tags = {
      name = "${var.env_prefix}-webserver01-${count.index + 1}"
       SSM  = "Enabled" 
    }   
}
