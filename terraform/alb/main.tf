terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
}

provider "aws" {
	region = "ap-south-1"
}

resource "aws_lb" "ALB" {
	name = "terraform-alb"
	internal = false
	load_balancer_type = "application"
	security_groups = var.alb-sg-id
	subnets = var.public-subnet-ids
	idle_timeout = 400
	enable_deletion_protection = true
	ip_address_type = "ipv4"
	tags = {
		Name = "terraform-alb"
	}
}

resource "aws_lb_target_group" "tartgetGroup" {
	load_balancing_algorithm_type = var.alb-algorithm-type
	name = "terraform-TG"
	port = var.tg-port
	protocol = var.albProtocol
	slow_start = 30
	tags = {
		Name = "terraform-TG"
	}
	target_type = "instance"
	vpc_id = var.vpc-id
	health_check {
		enabled = true
		healthy_threshold = 4
		interval = 60
		path = "/"
		port = var.tg-port
		protocol = var.albProtocol
		timeout = 10
		unhealthy_threshold = 2
	}
}

resource "aws_lb_listener" "ALBListener" {
	depends_on = [aws_lb.ALB,aws_lb_target_group.tartgetGroup]
	load_balancer_arn = aws_lb.ALB.arn
	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.tartgetGroup.arn
		order = 1
	}
	port = var.alb-port
	protocol = var.albProtocol
	certificate_arn = var.sslCertARN
}

resource "aws_lb_listener_rule" "ALBFixedResponseRule" {
	depends_on = [aws_lb_listener.ALBListener]
	listener_arn = aws_lb_listener.ALBListener.id
	priority = 30
	action {
		type = "fixed-response"
		fixed_response {
			content_type = "text/plain"
			message_body = "This is fixed response. Logout page is yet to create."
			status_code = 200
		}
	}
	condition {
		path_pattern {
			values = ["/Logout"]
		}
	}
}

resource "aws_lb_listener_rule" "ALBRedirecteRule" {
	depends_on = [aws_lb_listener.ALBListener]
	listener_arn = aws_lb_listener.ALBListener.id
	priority = 35
	action {
		type = "redirect"
		redirect {
			path = "/"
			status_code = "HTTP_301"
		}
	}
	condition {
		path_pattern {
			values = ["/home"]
		}
	}
}