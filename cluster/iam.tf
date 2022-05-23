resource "aws_iam_policy" "eks-temporary-additional" {
  name = "${var.cluster_name}-additional-temporary"
  description = "Temporary permissions for nodes"
  policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "ec2:*",
                "elasticloadbalancing:*",
                "cloudwatch:*",
                "autoscaling:*",
                "dynamodb:*",
                "events:*",
                "cloudformation:*",
                "lambda:*",
                "logs:*",
                "sqs:*",
                "elasticache:*",
                "elasticmapreduce:*",
                "elasticbeanstalk:*",
                "ecs:*",
                "ecr:*",
                "rds:*",
                "codebuild:*",
                "route53:*",
                "application-autoscaling:*",
                "s3:HeadBucket",
                "s3:ListAllMyBuckets",
                "s3:GetAccountPublicAccessBlock",
                "ec2:DescribeTags",
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sns:Publish",
                "sns:GetTopicAttributes",
                "kinesis:Get*",
                "kinesis:List*",
                "kinesis:Describe*",
                "iam:PassRole",
                "iam:AttachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:GetInstanceProfile",
                "iam:ListInstanceProfiles",
                "iam:AddRoleToInstanceProfile",
                "iam:AttachRolePolicy",
                "kms:*",
                "secretsmanager:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "cloudwatch:*",
                "autoscaling:*",
                "dynamodb:*",
                "events:*",
                "cloudformation:*",
                "lambda:*",
                "logs:*",
                "sqs:*",
                "elasticache:*",
                "elasticmapreduce:*",
                "elasticbeanstalk:*",
                "ecs:*",
                "ecr:*",
                "rds:*",
                "codebuild:*",
                "route53:*",
                "application-autoscaling:*",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "ec2:DescribeTags",
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "sns:Publish",
                "sns:GetTopicAttributes",
                "kinesis:Get*",
                "kinesis:List*",
                "kinesis:Describe*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": [
                "arn:aws:iam::375164415270:role/nodes.ganymede.preprod.olxbr.cloud",
                "arn:aws:iam::375164415270:role/cops-app-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:CreateBucket",
                "s3:DeleteBucket"
            ],
            "Resource": [
                "arn:aws:s3:::vault-storage-preprod/*",
                "arn:aws:s3:::vault-storage-preprod"
            ]
        }
    ]
    }
  )
}