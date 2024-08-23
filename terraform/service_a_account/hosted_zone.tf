resource "aws_route53_zone" "simpleapp_mesh_local" {
  name         = "simpleapp.mesh.local."
  vpc {
    vpc_id = "${aws_vpc.example.id}"
  }
}

resource "aws_route53_record" "all" {
  zone_id = aws_route53_zone.simpleapp_mesh_local.zone_id
  name    = "*.${aws_route53_zone.simpleapp_mesh_local.name}"
  type    = "A"
  ttl     = "300"
  records = ["1.2.3.4"]
}