module "mesh_account" {
  source = "./mesh_account"

  service_a_account_number = var.service_a_account_number
  service_b_account_number = var.service_b_account_number

  providers = {
    aws = aws.mesh_account
  }
}

module "service_a_account" {
  source = "./service_a_account"

  region = var.region
  mesh_account_number = var.mesh_account_number
  service_a_account_number = var.service_a_account_number
  service_a_account_profile = var.service_a_account_profile
  service_a_account_vpc_cidr_range = var.service_a_account_vpc_cidr_range
  service_a_account_subnet_cidr_range = var.service_a_account_subnet_cidr_range
  aws_ram_resource_share_arn = module.mesh_account.aws_ram_resource_share_arn
  appmesh_id = module.mesh_account.appmesh_id
  transit_gateway_id = module.mesh_account.transit_gateway_id

  providers = {
    aws = aws.service_a_account
  }

  depends_on = [
    module.mesh_account
  ]
}

module "service_b_account" {
  source = "./service_b_account"

  region = var.region
  mesh_account_number = var.mesh_account_number
  service_b_account_number = var.service_b_account_number
  service_b_account_profile = var.service_b_account_profile
  service_b_account_vpc_cidr_range = var.service_b_account_vpc_cidr_range
  service_b_account_subnet_cidr_range = var.service_b_account_subnet_cidr_range
  aws_ram_resource_share_arn = module.mesh_account.aws_ram_resource_share_arn
  appmesh_id = module.mesh_account.appmesh_id
  transit_gateway_id = module.mesh_account.transit_gateway_id

  providers = {
    aws = aws.service_b_account
  }

  depends_on = [
    module.mesh_account
  ]
}
