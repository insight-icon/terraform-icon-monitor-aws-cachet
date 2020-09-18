resource "aws_iam_role" "this" {
  count              = var.create ? 1 : 0
  name               = "MonitorNodeRole${title(var.name)}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "this" {
  count = var.create ? 1 : 0

  role = join("", aws_iam_role.this.*.name)
}


resource "aws_iam_policy" "s3_put_logs_policy" {
  count = var.create ? 1 : 0

  policy = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid":"ReadWrite",
          "Effect":"Allow",
          "Action":["s3:GetObject", "s3:PutObject"],
          "Resource":["arn:aws:s3:::${aws_s3_bucket.backend.*.bucket[0]}/*"]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "s3_put_logs_policy" {
  count = var.create ? 1 : 0

  role = join("", aws_iam_role.this.*.id)

  policy_arn = aws_iam_policy.s3_put_logs_policy.*.arn[0]
}