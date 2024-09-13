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
resource "aws_subnet" "public_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_c_cidr_block
  availability_zone = var.availability_zone_c
  map_public_ip_on_launch = true
  tags = {
    Name = "Publict-sub-c"
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
resource "aws_subnet" "private_sub_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_c_cidr_block
  availability_zone = var.availability_zone_c

  tags = {
    Name = "Private-sub-c"
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
resource "aws_route_table_association" "public_rt_as_public_subnet_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
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
resource "aws_route_table_association" "private_rt_2_as_private_subnet_c" {
  subnet_id      = aws_subnet.private_sub_c.id
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
  key_name = "team_seoul"

  tags = {
    Name = "Nat-1"
  }
}

# NAT EC2 2 인스턴스 생성
resource "aws_instance" "nat_2" {
  ami                    = "ami-0c2d3e23e757b5d84" # AWS 리전에 따라 적절한 AMI ID로 변경하세요.
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_c.id
  private_ip             = "10.1.2.100"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  source_dest_check      = false
  key_name = "team_seoul"

  tags = {
    Name = "Nat-2"
  }
}

# 배스쳔 EC2 인스턴스 생성
resource "aws_instance" "ec2_test" {
  ami                    = "ami-0c0dea96ae6850ced" # AWS 리전에 따라 적절한 AMI ID로 변경하세요.
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_c.id
  private_ip             = "10.1.2.200"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  source_dest_check      = false
  key_name = "team_seoul"

  tags = {
    Name = "EC2-TEST"
  }
}

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

# SSH 인바운드 규칙
resource "aws_security_group_rule" "allow_server_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance_sg.id

  from_port   = 22
  to_port     = 22
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
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_c.id]
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

# EKS IAM 생성
resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo-cluster.name
}

# EKS 보안그룹
resource "aws_security_group" "eks_sg" {
  name = "eks_sg"
  vpc_id = aws_vpc.vpc.id
}

# 아웃바운드 규칙
resource "aws_security_group_rule" "allow_all_outbound_eks" {
  type              = "egress"
  security_group_id = aws_security_group.eks_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# EKS 클러스터 생성
resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  role_arn = aws_iam_role.demo-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_sg.id]
    subnet_ids         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_c.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSVPCResourceController,
  ]
}

# EKS 노드 IAM 생성
resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "TEST-node-group"
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_c.id]
  instance_types  = [ "t3.small" ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
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

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}