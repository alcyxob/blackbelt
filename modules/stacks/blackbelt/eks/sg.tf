data "aws_subnet_ids" "private" {
  vpc_id = var.eks_vpc_id

  tags = {
    "${var.eks_subnet_tag_name}" = "${var.eks_subnet_tag_value}"
  }
}

//data "aws_subnet" "eks" {
//  count = length(data.aws_subnet_ids.private.ids)
//
//  id = data.aws_subnet_ids.private.ids[count.index]
//}

resource "aws_security_group" "eks_sg" {
  # checkov:skip=CKV_AWS_23:Ensure every security groups rule has a description
  name        = "eks-demo-sgbis"
  description = "sample security group for EKS"
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "eks_sg_ssh" {
  # checkov:skip=CKV_AWS_23:Ensure every security groups rule has a description
  name        = "eks-demo-ssh"
  description = "sample security group for EKS"
  vpc_id      = var.eks_vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
