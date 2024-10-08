variable "aws_region" {
  type        = string
  default = "ap-northeast-2"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.1.0.0/16"
}

# 퍼블릭 서브넷 A CIDR Block
variable "public_subnet_a_cidr_block" {
  description = "The CIDR block for the public subnet A."
  type        = string
  default     = "10.1.1.0/24"
}

# 퍼블릭 서브넷 C CIDR Block
variable "public_subnet_c_cidr_block" {
  description = "The CIDR block for the public subnet B."
  type        = string
  default     = "10.1.2.0/24"
}

# 프라이빗 서브넷 A CIDR Block
variable "private_subnet_a_cidr_block" {
  description = "The CIDR block for the private subnet A."
  type        = string
  default     = "10.1.3.0/24"
}

# 프라이빗 서브넷 C CIDR Block
variable "private_subnet_c_cidr_block" {
  description = "The CIDR block for the private subnet B."
  type        = string
  default     = "10.1.4.0/24"
}

# EKS 클러스터 이름
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "TEST"
}

# EKS 클러스터 버전
variable "cluster_version" {
  description = "The version of the EKS cluster."
  type        = string
  default     = "1.30" # EKS 클러스터의 기본 버전
}

# 인스턴스 타입
variable "instance_type" {
  description = "The instance type for the launch configuration."
  type        = string
  default     = "t3.small"
}

# 서버 HTTP 포트
variable "server_port_http" {
  description = "The HTTP port for the server."
  type        = number
  default     = 80
}

# 서버 HTTPS 포트
variable "server_port_https" {
  description = "The HTTPS port for the server."
  type        = number
  default     = 443
}

# IAM Role Policy Prefix
variable "iam_role_policy_prefix" {
  description = "The prefix for IAM role policies used by the cluster."
  type        = string
}

# Cluster Autoscaler IAM Policy Name
variable "iam_policy_autoscaling" {
  description = "The name of the IAM policy for the Cluster Autoscaler."
  type        = string
}

# Availability Zone A
variable "availability_zone_a" {
  description = "The availability zone for subnet A."
  type        = string
  default     = "ap-northeast-2a"
}

# Availability Zone B
variable "availability_zone_c" {
  description = "The availability zone for subnet B."
  type        = string
  default     = "ap-northeast-2c"
}

# Security Group for Instances
variable "instance_sg_name" {
  description = "The name of the security group for instances."
  type        = string
  default     = "instance-sg"
}

# Security Group for ALB
variable "alb_sg_name" {
  description = "The name of the security group for the ALB."
  type        = string
  default     = "alb-sg"
}

data "aws_caller_identity" "current" {}