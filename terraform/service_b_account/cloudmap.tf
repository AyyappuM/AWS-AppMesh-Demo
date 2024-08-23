resource "aws_service_discovery_http_namespace" "example" {
  name        = "simpleapp.local"
  description = "example"
}

resource "aws_service_discovery_service" "example" {
	name = "serviceb"
	
	type = "HTTP"
	namespace_id = aws_service_discovery_http_namespace.example.id

	#dns_config {
  #  namespace_id = aws_service_discovery_http_namespace.example.id

  #  dns_records {
  #    ttl  = 10
  #    type = "A"
  #  }
  #}
}