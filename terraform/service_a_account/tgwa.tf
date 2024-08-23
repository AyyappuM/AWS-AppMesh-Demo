resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id = "${aws_vpc.example.id}"
  subnet_ids          = ["${aws_subnet.private_subnet.id}"]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}