output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The domain name of the load balancer"
}

output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "private_subnet_a_id" {
  value = aws_subnet.private_sub_a.id
  description = "The ID of the private subnet A"
}

output "private_subnet_b_id" {
  value = aws_subnet.private_sub_b.id
  description = "The ID of the private subnet B"
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
  description = "The ID of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The endpoint of the EKS cluster"
}

output "eks_cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "The certificate authority data for the EKS cluster"
}