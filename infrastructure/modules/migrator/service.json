[
  {
    "name": "${service_name}",
    "environment": [
      {
        "name": "DATABASE_URL",
        "value": "postgresql://${database_username}:${database_password}@${database_endpoint}/${database_name}"
      }
    ],
    "command": ["migrate"],
    "image": "${ecr_repository_url}:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${cloudwatch_log_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${service_name}"
      }
    }
  }
]
