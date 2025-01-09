output "s3_bucket_name" {
  value = aws_s3_bucket.frontend_bucket.id
  description = "Name of the S3 bucket"
}



output "website_url" {
  value       = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
  description = "The regional domain name of the S3 bucket"
}

