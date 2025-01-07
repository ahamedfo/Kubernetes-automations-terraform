# kubernetes cluster


module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 4.0"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "terraform_auto_proj_cluster"
  cluster_version = "1.27"

#   cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true


  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.micro"]
    }
  }
}

resource "aws_security_group" "loadbalancer" {
  name_prefix = "eks-worker-nodes"

  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow traffic from the EKS control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic within the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "eks_api_server" {
    type = "ingress"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = []
    ipv6_cidr_blocks = ["2600:480a:51d2:5500:e557:ac80:4b17:26c1/128"]
    security_group_id = module.eks.cluster_security_group_id
  
}