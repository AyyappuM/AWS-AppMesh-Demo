resource "aws_ec2_transit_gateway" "example" {
  description = "example"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name        = "Shared-TGW"
  }
}
