[
  {
    "name": "${service_name}",
    "environment": [
      {
        "name": "DATABASE_URL",
        "value": "postgresql://${database_username}:${database_password}@${database_endpoint}/${database_name}"
      },
      {
        "name": "REDIS_URL",
        "value": "redis://${redis_endpoint}/1"
      },
      {
        "name": "TOPSHOT_ADDRESS",
        "value": "0b2a3299cc857e29"
      },
      {
        "name": "TOPSHOT_MARKET_ADDRESS",
        "value": "c1e4f4f4c4257510"
      },
      {
        "name": "TOPSHOT_EVENT_TYPE_PREFIX",
        "value": "A.c1e4f4f4c4257510"
      },
      {
        "name": "TOPSHOT_NODE",
        "value": "https://access-mainnet-beta.onflow.org"
      }
    ],
    "command": ["${join("\",\"", command)}"],
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
