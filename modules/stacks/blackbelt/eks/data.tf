data "aws_vpcs" "eks_vpc" {
  tags = {
    eks_vpc_tag_kv["key"] = eks_vpc_tag_kv["value"]
  }
}
