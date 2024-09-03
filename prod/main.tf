provider "aws" {
  region = var.aws_region
}

module "webserver_cluster" {
  source = "../modules/services/webserver-cluster"
  
  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids

  iam_role_policy_prefix = var.iam_role_policy_prefix
  iam_policy_autoscaling = var.iam_policy_autoscaling
  instance_sg_name       = var.instance_sg_name
  alb_sg_name            = var.alb_sg_name
}

provider "helm" {
  kubernetes {
    host                   = module.webserver_cluster.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(module.webserver_cluster.cluster_certificate_authority_data)
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.webserver_cluster.cluster_id
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [module.webserver_cluster]

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }

  set {
    name  = "extraArgs.scale-down-unneeded-time"
    value = "10m"
  }

  set {
    name  = "extraArgs.scale-down-delay-after-add"
    value = "10m"
  }
}
