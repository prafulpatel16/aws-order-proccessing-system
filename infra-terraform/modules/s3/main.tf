resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.web_bucket

  website {
    index_document = var.index_doc
    error_document = var.error_doc
  }

  tags = {
    Name        = var.web_bucket
    Environment = var.environment
  }
}

# Define the S3 bucket for Lambda deployment
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket
 


}



# Add a separate resource for public access block (if public access is needed)
resource "aws_s3_bucket_public_access_block" "frontend_bucket_access_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}

# Ensure the build directory exists and files are uploaded without ACLs
resource "null_resource" "frontend_build_sync" {
  provisioner "local-exec" {
    command = "aws s3 sync ../frontend/build s3://${aws_s3_bucket.frontend_bucket.bucket} --delete"
  }

  depends_on = [aws_s3_bucket.frontend_bucket, aws_s3_bucket_policy.frontend_policy]
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  index_document {
    suffix = var.index_doc
  }

  error_document {
    key = var.error_doc
  }
}