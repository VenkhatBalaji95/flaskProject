output "albARN" {
	value = aws_lb.ALB.arn
	description = "ALB ARN"
}

output "albDNS" {
	value = aws_lb.ALB.dns_name
	description = "ALB DNS name"
}

output "tgARN" {
	value = aws_lb_target_group.tartgetGroup.arn
	description = "Target group ARN"
}

output "listenerARN" {
	value = aws_lb_listener.ALBListener.id
	description = "ALB listener ARN"
}