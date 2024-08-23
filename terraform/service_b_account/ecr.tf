resource "aws_ecr_repository" "service_b_ecr_repository" {
  name = "service_b_ecr_repository"
}

output "service_b_ecr_repository_url" {
	value = aws_ecr_repository.service_b_ecr_repository.repository_url
}

resource "null_resource" "docker_build_and_push" {
	provisioner "local-exec" {
		command = <<EOT
			aws ecr get-login-password --region ${var.region} --profile ${var.service_b_account_profile} | docker login --username AWS --password-stdin ${aws_ecr_repository.service_b_ecr_repository.repository_url}
			ls ${path.module}
			docker build -t service_b_image "${path.module}/../../app/ServiceB"
			docker tag service_b_image:latest ${aws_ecr_repository.service_b_ecr_repository.repository_url}:latest
			docker push ${aws_ecr_repository.service_b_ecr_repository.repository_url}:latest
		EOT
	}

	depends_on = [aws_ecr_repository.service_b_ecr_repository]
}

resource "null_resource" "destroy_ecr_repository" {
	triggers = {
		service_b_ecr_repository_name = aws_ecr_repository.service_b_ecr_repository.name
		service_b_account_profile = var.service_b_account_profile
	}

	provisioner "local-exec" {
		when = destroy
		command = <<EOT
			aws ecr delete-repository --repository-name ${self.triggers.service_b_ecr_repository_name} --force --profile ${self.triggers.service_b_account_profile}
		EOT
	}

	depends_on = [aws_ecr_repository.service_b_ecr_repository]
}