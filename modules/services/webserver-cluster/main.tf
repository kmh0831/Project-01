# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Project-vpc"
  }
}

# 인터넷게이트웨이
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "vpc-igw"
  }
}

# 퍼블릭 서브넷 A
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_a_cidr_block
  availability_zone = var.availability_zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "Publict-sub-a"
  }
}

# 퍼블릭 서브넷 B
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_b_cidr_block
  availability_zone = var.availability_zone_c
  map_public_ip_on_launch = true
  tags = {
    Name = "Publict-sub-b"
  }
}

# 프라이빗 서브넷 A
resource "aws_subnet" "private_sub_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_a_cidr_block
  availability_zone = var.availability_zone_a

  tags = {
    Name = "Private-sub-a"
  }
}

# 프라이빗 서브넷 B
resource "aws_subnet" "private_sub_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_b_cidr_block
  availability_zone = var.availability_zone_c

  tags = {
    Name = "Private-sub-b"
  }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = local.all_ip
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# 퍼블릭 서브넷 A - 퍼블릭 RT 연결
resource "aws_route_table_association" "public_rt_as_public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# 퍼블릭 서브넷 B - 퍼블릭 RT 연결
resource "aws_route_table_association" "public_rt_as_public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# 프라이빗 라우팅 테이블 1
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block           = local.all_ip
    network_interface_id = aws_instance.nat_1.primary_network_interface_id
  }

  tags = {
    Name = "Private-RT-1"
  }
}

# 프라이빗 라우팅 테이블 2
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block           = local.all_ip
    network_interface_id = aws_instance.nat_1.primary_network_interface_id
  }

  tags = {
    Name = "Private-RT-2"
  }
}

# 프라이빗 서브넷 A - 프라이빗 RT 1 연결
resource "aws_route_table_association" "private_rt_1_as_private_subnet_a" {
  subnet_id      = aws_subnet.private_sub_a.id
  route_table_id = aws_route_table.private_rt_1.id
}

# 프라이빗 서브넷 B - 프라이빗 RT 2 연결
resource "aws_route_table_association" "private_rt_2_as_private_subnet_b" {
  subnet_id      = aws_subnet.private_sub_b.id
  route_table_id = aws_route_table.private_rt_2.id
}

# NAT 게이트웨이용 탄력적 IP 1
resource "aws_eip" "nat_eip_1" {
  domain   = "vpc"

  tags = {
    Name = "Nat-eip-1"
  }
}

# NAT 게이트웨이용 탄력적 IP 2
resource "aws_eip" "nat_eip_2" {
  domain   = "vpc"

  tags = {
    Name = "Nat-eip-2"
  }
}

# NAT EC2 1 인스턴스 생성
resource "aws_instance" "nat_1" {
  ami                    = "ami-0c2d3e23e757b5d84" # AWS 리전에 따라 적절한 AMI ID로 변경하세요.
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_a.id
  private_ip             = "10.1.1.100"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  source_dest_check      = false

  tags = {
    Name = "Nat-1"
  }
}

# NAT EC2 2 인스턴스 생성
resource "aws_instance" "nat_2" {
  ami                    = "ami-0c2d3e23e757b5d84" # AWS 리전에 따라 적절한 AMI ID로 변경하세요.
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_b.id
  private_ip             = "10.1.2.100"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  source_dest_check      = false

  tags = {
    Name = "Nat-2"
  }
}

# # 시작 템플릿 
# resource "aws_launch_configuration" "TEST" {
#   image_id        = "ami-07d737d4d8119ad79"
#   instance_type   = var.instance_type
#   security_groups = [aws_security_group.instance_sg.id]
#   user_data       = data.template_file.user_data.rendered

#   # 오토스케일링 그룹과 함께 시작 구성을 사용할 때 필요합니다.
#   # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # 시작 템플릿 유저데이터 데이터로 지정
# data "template_file" "user_data" {
#   template = file("${path.module}/user-data.sh")
# }

# 인스턴스 보안 그룹
resource "aws_security_group" "instance_sg" {
  name = var.instance_sg_name
  vpc_id = aws_vpc.vpc.id
}

# HTTP 인바운드 규칙
resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id

  from_port   = var.server_port_http
  to_port     = var.server_port_http
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# HTTPS 인바운드 규칙
resource "aws_security_group_rule" "allow_server_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id

  from_port   = var.server_port_https
  to_port     = var.server_port_https
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# 아웃바운드 규칙
resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# ALB
resource "aws_lb" "alb" {
  name               = var.cluster_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "TEST-ALB"
  }
}

# ALB 리스너
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# 타겟 그룹
resource "aws_lb_target_group" "target_group" {
  name     = var.cluster_name
  port     = var.server_port_http
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# # ALB 리스너 규칙
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# ALB 보안그룹
resource "aws_security_group" "alb_sg" {
  name = var.alb_sg_name
  vpc_id = aws_vpc.vpc.id
}

# HTTP 인바운드 규칙
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# HTTPS 인바운드 규칙
resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# 아웃바운드 규칙
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "example" {
  name     = "example-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.private_sub_a.id, aws_subnet.private_sub_b.id]
  }
}

# 클러스터에 필요한 IAM 역할
resource "aws_iam_role" "eks_cluster_role" {
  name = "example-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS 노드 그룹에 대한 IAM 역할 및 정책
resource "aws_iam_role" "eks_node_group_role" {
  name = "example-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS 노드 그룹
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.private_sub_a.id, aws_subnet.private_sub_b.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.small"]

  remote_access {
    ec2_ssh_key = "team_seoul"
  }
}

# OIDC 공급자 설정 (IRSA용)
data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.example.name
}

data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.example.name
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.example.identity[0].oidc.issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.aws_eks_cluster_auth.example.cluster_certificate_authority[0].data
  ]
}

# Cluster Autoscaler용 IAM 역할 및 정책
resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "eks-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" : {
            "${replace(data.aws_eks_cluster.example.identity[0].oidc.issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

# 사용자 정의 정책 (필요한 권한 정의)
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "eks-cluster-autoscaler-policy"
  description = "Policy for EKS Cluster Autoscaler to manage EC2 and ASG"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        Resource = "*"
      },
    ],
  })
}

# 사용자 정의 정책을 IAM 역할에 부착
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_custom_policy_attachment" {
  role       = aws_iam_role.cluster_autoscaler_role.name
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

# Cluster Autoscaler 서비스 계정 생성 및 IAM 역할 연결
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role.arn
    }
  }
}


# 로컬 변수
locals {
  http_port    = 80
  https_port   = 443
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ip       = "0.0.0.0/0"
  all_ips      = ["0.0.0.0/0"]
}