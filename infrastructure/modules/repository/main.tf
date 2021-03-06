resource "aws_ecr_repository" "repository" {
  name = var.name
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than ${var.expiry_days} day(s)",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.expiry_days}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
