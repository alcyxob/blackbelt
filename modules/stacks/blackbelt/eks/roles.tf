/* EKS Service Main Roles: Master */
resource "aws_iam_role" "eks-master" {

  name        = "eks-master-${var.cluster_name}-${var.region}"
  description = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  path        = "/"

  assume_role_policy = <<EKS_MASTER_ROLE_POLICY
${jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  }
)}
EKS_MASTER_ROLE_POLICY

tags = {
  Name = "eks-master-${var.cluster_name}-${var.region}"
}

} /* resource "aws_iam_role" "eks-master" ends here. */


/* Nodes + Instance Profile with the same name */
resource "aws_iam_role" "eks-nodes" {

  name        = "eks-nodes-${var.cluster_name}-${var.region}"
  description = "Allows EC2 instances to call AWS services on your behalf"
  path        = "/"

  assume_role_policy = <<EKS_NODES_ROLE_POLICY
${jsonencode(
  {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  }
)}
EKS_NODES_ROLE_POLICY

tags = {
  Name = "eks-nodes-${var.cluster_name}-${var.region}"
}

} /* resource "aws_iam_role" "eks-nodes" ends here. */

/* and this same role is the instance profile for the Launch Configuration */
resource "aws_iam_instance_profile" "eks-nodes" {

  name = "eks-nodes-${var.cluster_name}-${var.region}"
  role = aws_iam_role.eks-nodes.name
  path = "/"

}

#resource "aws_iam_role" "aws-load-balancer-controller" {
#  name = "eks-alb-controller-${var.cluster_name}-${var.region}"
#  description = "Allows EC2 instances to call AWS services on your behalf"
#  path        = "/"
#
#  assume_role_policy = <<EKS_NODES_ROLE_POLICY
#${jsonencode(
#  {
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Effect" : "Allow",
#        "Principal" : {
#          "Service" : "ec2.amazonaws.com"
#        },
#        "Action" : "sts:AssumeRole"
#      }
#    ]
#  }
#)}
#EKS_NODES_ROLE_POLICY
#
#  tags = {
#    Name = "eks-nodes-${var.cluster_name}-${var.region}"
#  }
#
#}
