resource "aws_ecr_repository" "api-gateway" {
  name                 = "${var.p_name}_api-gateway-lambda-main"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}
#***************************************************************************************************
resource "aws_ecr_repository" "availability" {
  name                 = "${var.p_name}_availability-lambda-main"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

#***************************************************************************************************
resource "aws_ecr_repository" "reservation" {
  name                 = "${var.p_name}_reservation-main"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}
#***************************************************************************************************
# Push Docker Image to ECR
resource "null_resource" "docker_image_push" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --profile ${var.aws_cli_profile} --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      docker build -f ../../../../.ops/Dockerfile -t api_gateway ../../../../
      docker tag api_gateway:latest ${aws_ecr_repository.api-gateway.repository_url}:latest
      docker push ${aws_ecr_repository.api-gateway.repository_url}:latest

      aws ecr get-login-password --profile ${var.aws_cli_profile} --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      docker build -f ../../../../.ops/Dockerfile_availability -t availability ../../../../
      docker tag availability:latest ${aws_ecr_repository.availability.repository_url}:latest
      docker push ${aws_ecr_repository.availability.repository_url}:latest

      aws ecr get-login-password --profile ${var.aws_cli_profile} --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      docker build -f ../../../../.ops/Dockerfile_reservation -t reservation ../../../../
      docker tag reservation:latest ${aws_ecr_repository.reservation.repository_url}:latest
      docker push ${aws_ecr_repository.reservation.repository_url}:latest
    EOT
  }

    triggers = {
    python_files_hash = join("", [
      filesha256("../../../../lambda_functions/check_availability.py"),
      filesha256("../../../../lambda_functions/reserve_court.py")
    ])
  }

  depends_on = [
    aws_ecr_repository.api-gateway,
    aws_ecr_repository.availability,
    aws_ecr_repository.reservation
    ]
}