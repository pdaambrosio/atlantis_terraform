resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags = var.tags
}

resource "aws_s3_bucket_acl" "acl_s3" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
            {
            "Sid": "Only allow specific role",
            "Effect": "allow",
            "Principal":{
              "Service": "ec2.amazonaws.com"
            },
            "Action":  "s3:*",
            "Resource": "${aws_s3_bucket.bucket.arn}/*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket_object" "object" {
  for_each = fileset("${var.filename}/", "**/*")
  bucket   = aws_s3_bucket.bucket.id
  key      = each.value
  acl      = var.acl
  source   = "${var.filename}/${each.value}"
  etag     = filemd5("${var.filename}/${each.value}")
}