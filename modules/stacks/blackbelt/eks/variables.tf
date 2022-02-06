variable "region" {}
variable "eks_cluster_name" {}
variable "eks_vpc_id" {}
/* IAM Roles mapped in RBAC to authenticate the users belonging to those Roles */
variable "eks_aws_managed_policies" {
  type    = list(any)
  default = ["arn:aws:iam::aws:policy/AmazonEKSServicePolicy", "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}
/* -------------------------------------------- */
variable "eks_version" {}
variable "eks_min_capacity" {}
variable "eks_max_capacity" {}
variable "eks_private_subnet_ids" {}
variable "eks_subnet_tag_name" {}
variable "eks_subnet_tag_value" {}
variable "eks_node_type" {}
variable "eks_ec2_volume_size" {}
variable "eks_node_ami" {}
variable "eks_keypair_name" {}
