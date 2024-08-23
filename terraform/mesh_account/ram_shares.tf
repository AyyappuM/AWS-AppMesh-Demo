resource "aws_ram_resource_share" "example" {  
  name                      = "example"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "share_appmesh_with_service_a_account" {
  principal          = var.service_a_account_number
  resource_share_arn = aws_ram_resource_share.example.arn
}

resource "aws_ram_principal_association" "share_appmesh_with_service_b_account" {
  principal          = var.service_b_account_number
  resource_share_arn = aws_ram_resource_share.example.arn
}

resource "aws_ram_resource_association" "share_appmesh" {
  resource_arn       = aws_appmesh_mesh.example.arn
  resource_share_arn = aws_ram_resource_share.example.arn
}

resource "aws_ram_resource_association" "share_tgw" {
  resource_arn       = aws_ec2_transit_gateway.example.arn
  resource_share_arn = aws_ram_resource_share.example.arn
}
