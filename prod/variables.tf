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
  default     = "1.27" # EKS 클러스터의 기본 버전 (필요에 따라 변경 가능)
}

# AWS 리전
variable "aws_region" {
  description = "The AWS region where the EKS cluster and other resources will be created."
  type        = string
  default     = "ap-northeast-2" # 필요에 따라 변경 가능
}

# VPC ID
variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster and associated resources will be deployed."
  type        = string
}

# 서브넷 ID 목록
variable "subnet_ids" {
  description = "The list of private subnet IDs for the EKS cluster."
  type        = list(string)
}

# AWS Account ID
variable "account_id" {
  description = "The AWS Account ID where the resources will be created."
  type        = string
}

variable "iam_role_policy_prefix" {
  description = "The prefix for IAM role policies used by the cluster."
  type        = string
  default     = "eks-cluster"
}

variable "iam_policy_autoscaling" {
  description = "The name of the IAM policy for the Cluster Autoscaler."
  type        = string
  default     = "eks-cluster-autoscaler-policy"
}

variable "instance_sg_name" {
  description = "The name of the security group for instances."
  type        = string
  default     = "instance-sg"
}

variable "alb_sg_name" {
  description = "The name of the security group for the ALB."
  type        = string
  default     = "alb-sg"
}

# data 블록을 통해 현재 AWS 계정 ID를 가져옵니다.
data "aws_caller_identity" "current" {}
