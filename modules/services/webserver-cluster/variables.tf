# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# 퍼블릭 서브넷 A CIDR Block
variable "public_subnet_a_cidr_block" {
  description = "The CIDR block for the public subnet A."
  type        = string
  default     = "10.1.1.0/24"
}

# 퍼블릭 서브넷 B CIDR Block
variable "public_subnet_b_cidr_block" {
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

# 프라이빗 서브넷 B CIDR Block
variable "private_subnet_b_cidr_block" {
  description = "The CIDR block for the private subnet B."
  type        = string
  default     = "10.1.4.0/24"
}

# EKS 클러스터 이름
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "Project-TEST"
}

# EKS 클러스터 버전
variable "cluster_version" {
  description = "The version of the EKS cluster."
  type        = string
  default     = "1.27" # EKS 클러스터의 기본 버전
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
variable "availability_zone_b" {
  description = "The availability zone for subnet B."
  type        = string
  default     = "ap-northeast-2b"
}

# AMI ID
variable "ami_id" {
  description = "The AMI ID for the launch configuration."
  type        = string
  default     = "ami-07d737d4d8119ad79"
}

# Security Group for Instances
variable "instance_sg_name" {
  description = "The name of the security group for instances."
  type        = string
  default     = "${var.cluster_name}-instance"
}

# Security Group for ALB
variable "alb_sg_name" {
  description = "The name of the security group for the ALB."
  type        = string
  default     = "${var.cluster_name}-alb"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster and associated resources will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "The list of private subnet IDs for the EKS cluster."
  type        = list(string)
}
