# 백엔드 설정
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-kmhyuk0831"
    key            = "path/to/your/terraform.tfstate"  # tfstate 파일 경로
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "../modules/services/webserver-cluster"
  
  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  vpc_cidr_block               = "10.1.0.0/16"
  private_subnet_a_cidr_block  = "10.1.3.0/24"
  private_subnet_c_cidr_block  = "10.1.4.0/24"
  availability_zone_a          = "ap-northeast-2a"
  availability_zone_c          = "ap-northeast-2c"

  iam_role_policy_prefix = var.iam_role_policy_prefix
  iam_policy_autoscaling = var.iam_policy_autoscaling
  instance_sg_name       = var.instance_sg_name
  alb_sg_name            = var.alb_sg_name
}

# provider "helm" {
#   kubernetes {
#     host                   = module.webserver_cluster.eks_cluster_endpoint
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     cluster_ca_certificate = base64decode(module.webserver_cluster.eks_cluster_certificate_authority_data)
#   }
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.webserver_cluster.eks_cluster_name
# }

# resource "helm_release" "cluster_autoscaler" {
#   depends_on = [module.webserver_cluster]

#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.cluster_name
#   }

#   set {
#     name  = "awsRegion"
#     value = var.aws_region
#   }

#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = module.webserver_cluster.cluster_autoscaler_role_arn
#   }

#   set {
#     name  = "extraArgs.scale-down-unneeded-time"
#     value = "10m"
#   }

#   set {
#     name  = "extraArgs.scale-down-delay-after-add"
#     value = "10m"
#   }
# }

