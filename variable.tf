variable "profile" {
  description = "AWS User account Profile"
}

variable "region" {
  default = "us-east-1"
}

variable "key" {
  description = "Enter Key name"
}

variable "sub_ids" {
  default = []
}

variable "instance-ami" {
  default = "ami-00afc256a955c31b5" # AMI of Mumbai region
}

variable "instance_type" {
  default = "t3a.medium"
}


variable "cluster-name" {
  description = "Cluster Name"
}

variable "server-name" {
  description = "Ec2 Server Name"
}

variable "vpc_name" {
  description = "VPC name"
}
  
