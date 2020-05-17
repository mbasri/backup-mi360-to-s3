{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:ListBucket",
        "s3:PutObjectTagging",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${bucket_arn}/*",
        "${bucket_arn}"
      ]
    }
  ]
}