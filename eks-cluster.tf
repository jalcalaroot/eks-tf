locals {
  cluster_name = "noprod-eks-inkhealth-${random_string.suffix.result}"
}


resource "random_string" "suffix" {
  length  = 4
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.22.6":
  subnets         = ["subnet-09db50623a8f31326", "subnet-0a8128188062b2435", "subnet-059d93a0d3918d586"]

  vpc_id = "vpc-09bf547bfdc87e81f"

  workers_group_defaults = {
    root_volume_type = "gp3"
    enable_monitoring = "true"
    root_volume_size = "100"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3a.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
  ]
}

#    {
#      name                          = "worker-group-2"
#      instance_type                 = "t2.medium"
#      additional_userdata           = "echo foo bar"
#      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
#      asg_desired_capacity          = 0
#    },
#  ]
#}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
