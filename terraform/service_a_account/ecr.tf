resource "aws_ecr_repository" "service_a_ecr_repository" {
  name = "service_a_ecr_repository"
}

output "service_a_ecr_repository_url" {
	value = aws_ecr_repository.service_a_ecr_repository.repository_url
}

resource "null_resource" "docker_build_and_push" {
	provisioner "local-exec" {
		command = <<EOT
			aws ecr get-login-password --region ${var.region} --profile ${var.service_a_account_profile} | docker login --username AWS --password-stdin ${aws_ecr_repository.service_a_ecr_repository.repository_url}
			ls ${path.module}
			docker build -t service_a_image "${path.module}/../../app/ServiceA"
			docker tag service_a_image:latest ${aws_ecr_repository.service_a_ecr_repository.repository_url}:latest
			docker push ${aws_ecr_repository.service_a_ecr_repository.repository_url}:latest
		EOT
	}

	depends_on = [aws_ecr_repository.service_a_ecr_repository]
}

resource "null_resource" "destroy_ecr_repository" {
	triggers = {
		service_a_ecr_repository_name = aws_ecr_repository.service_a_ecr_repository.name
		service_a_account_profile = var.service_a_account_profile
	}

	provisioner "local-exec" {
		when = destroy
		command = <<EOT
			aws ecr delete-repository --repository-name ${self.triggers.service_a_ecr_repository_name} --force --profile ${self.triggers.service_a_account_profile}
		EOT
	}

	depends_on = [aws_ecr_repository.service_a_ecr_repository]
}