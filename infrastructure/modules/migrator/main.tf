data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "task_role" {
  name = "topshothawk-${terraform.workspace}-${var.service_name}-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "task_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_role_policy_attachment" "task_role" {
  role       = aws_iam_role.task_role.name
  policy_arn = data.aws_iam_policy.task_policy.arn
}

resource "aws_iam_role" "execution_role" {
  name = "topshothawk-${terraform.workspace}-${var.service_name}-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "security_group" {
  name   = "topshothawk-${terraform.workspace}-${var.service_name}"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "all egress"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "topshothawk-${terraform.workspace}-${var.service_name}"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution_role.arn

  container_definitions = templatefile("${path.module}/service.json.tpl", {
    aws_region           = data.aws_region.current.name
    cloudwatch_log_group = "topshothawk-${terraform.workspace}"
    database_endpoint    = var.database_endpoint
    database_name        = var.database_name
    database_password    = var.database_password
    database_username    = var.database_username
    ecr_repository_url   = var.ecr_repository_url
    service_name         = var.service_name
  })
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "topshothawk-${terraform.workspace}-${var.service_name}"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "scheduled_task" {
  rule     = aws_cloudwatch_event_rule.event_rule.name
  arn      = var.ecs_cluster_id
  role_arn = aws_iam_role.task_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.task_definition.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets         = var.subnets
      security_groups = [aws_security_group.security_group.id]
    }
  }
}
