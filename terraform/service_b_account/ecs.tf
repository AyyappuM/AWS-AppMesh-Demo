# AWS ECS CLUSTER

resource "aws_ecs_cluster" "example" {
  name = "MyECSCluster"
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.example.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# ECS TASK ROLE

resource "aws_iam_role" "ECSTaskRole" {
  name                = "ECS_Task_Role"
  assume_role_policy  = file("${path.module}/assume-role-policy.json")
}

resource "aws_iam_policy" "ECSTaskRolePermissionsPolicy" {
  name        = "ECS_Task_Role_Permission_Policy"
  policy      = file("${path.module}/ecs-task-role-permission-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-customer-permission-policy-attachment" {
  role       = aws_iam_role.ECSTaskRole.name
  policy_arn = "${aws_iam_policy.ECSTaskRolePermissionsPolicy.arn}"
}

data "aws_iam_policy" "AWSAppMeshEnvoyAccess_Managed_Policy" {
  arn = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-AWSAppMeshEnvoyAccess-managed-policy-attachment" {
  role       = aws_iam_role.ECSTaskRole.name
  policy_arn = "${data.aws_iam_policy.AWSAppMeshEnvoyAccess_Managed_Policy.arn}"
}

# ECS TASK EXECUTION ROLE

resource "aws_iam_role" "ECSTaskExecutionRole" {
  name                = "ECS_Task_Execution_Role"
  assume_role_policy  = file("${path.module}/assume-role-policy.json")
}

resource "aws_iam_policy" "ECSTaskExecutionRolePermissionsPolicy" {
  name        = "ECS_Task_Execution_Role_Permission_Policy"
  policy      = file("${path.module}/ecs-task-execution-role-permission-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-customer-permission-policy-attachment" {
  role       = aws_iam_role.ECSTaskExecutionRole.name
  policy_arn = "${aws_iam_policy.ECSTaskExecutionRolePermissionsPolicy.arn}"
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy_Managed_Policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-AmazonECSTaskExecutionRolePolicy-managed-policy-attachment" {
  role       = aws_iam_role.ECSTaskExecutionRole.name
  policy_arn = "${data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy_Managed_Policy.arn}"
}

# ECS TASK DEFINITION

resource "aws_ecs_task_definition" "ecs_service" {
  family                   = "serviceb"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # APPMESH proxy configuration is only supported in networkMode=awsvpc
  memory = 2048
  cpu = 1024  
  execution_role_arn = aws_iam_role.ECSTaskExecutionRole.arn
  task_role_arn = aws_iam_role.ECSTaskRole.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile("${path.module}/container_definitions.json", {
    service_b_ecr_repository_url = aws_ecr_repository.service_b_ecr_repository.repository_url
    region = var.region
    service_b_account_number = var.service_b_account_number
    mesh_account_number = var.mesh_account_number
  })

  proxy_configuration {
    type           = "APPMESH"
    container_name = "envoy"
    properties = {
      AppPorts         = "8080"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      EgressIgnoredPorts = ""
      IgnoredUID       = "1337"
      IgnoredGID       = ""
      ProxyEgressPort  = 15001
      ProxyIngressPort = 15000
    }
  }
}

# ECS SERVICE

resource "aws_ecs_service" "serviceb" {
  name = "serviceb"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.ecs_service.arn
  desired_count   = 1
  enable_execute_command = true
  #force_new_deployment = false

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks_sg.id}"]
    subnets          = ["${aws_subnet.private_subnet.id}"]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  service_registries {
    registry_arn = aws_service_discovery_service.example.arn
  }
}

