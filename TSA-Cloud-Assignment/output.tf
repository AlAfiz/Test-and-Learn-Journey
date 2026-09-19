output "ec2_public_ip" {
  description = "The public IP of the backend EC2 instance"
  value       = aws_instance.backend_server.public_ip
}

output "cloudfront_url" {
  description = "The CloudFront domain name for the frontend"
  value       = aws_cloudfront_distribution.frontend_cdn.domain_name
}
