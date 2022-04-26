
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = "vpc-09bf547bfdc87e81f"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}


#resource "aws_security_group" "worker_group_mgmt_two" {
#  name_prefix = "worker_group_mgmt_two"
#  vpc_id      = module.vpc.vpc_id

#  ingress {
#    from_port = 22
#    to_port   = 22
#    protocol  = "tcp"

#    cidr_blocks = [
#      "10.0.0.0/8",
#    ]
#  }
#}

#resource "aws_security_group" "all_worker_mgmt" {
#  name_prefix = "all_worker_management"
#  vpc_id      = module.vpc.vpc_id

#  ingress {
#    from_port = 22
#    to_port   = 22
#    protocol  = "tcp"

#    cidr_blocks = [
#      "10.0.0.0/8",
#      "0.0.0.0/0",
#    ]
#  }
#}
