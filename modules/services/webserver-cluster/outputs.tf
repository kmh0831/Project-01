output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The domain name of the load balancer"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb_sg.id
  description = "The ID of the Security Group attached to the load balancer"
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets" {
  value = [aws_subnet.private-sub-a.id, aws_subnet.private-sub-b.id]
}