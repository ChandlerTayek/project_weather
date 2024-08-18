output "api_gateway_ecr_image_url" {
  value = aws_ecr_repository.api-gateway.repository_url
}

output "availability_ecr_image_url" {
  value = aws_ecr_repository.availability.repository_url
}

output "reservation_ecr_image_url" {
  value = aws_ecr_repository.reservation.repository_url
}

output "null_resource_docker_image_push" {
  value = null_resource.docker_image_push
}