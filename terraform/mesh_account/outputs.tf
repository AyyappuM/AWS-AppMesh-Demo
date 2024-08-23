output "aws_ram_resource_share_arn" {
	value = aws_ram_resource_share.example.arn
}

output "appmesh_id" {
	value = aws_appmesh_mesh.example.id
}

output "transit_gateway_id" {
	value = aws_ec2_transit_gateway.example.id
}