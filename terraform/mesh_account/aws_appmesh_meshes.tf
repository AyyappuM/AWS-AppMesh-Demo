resource "aws_appmesh_mesh" "example" {
  name = "MyAppMesh"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}
