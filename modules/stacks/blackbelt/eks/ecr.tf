resource "aws_ecr_repository" "quantexa_service_registry" {
  for_each             = toset(var.eks_quantexa_services)
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}
