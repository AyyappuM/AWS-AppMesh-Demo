resource "aws_appmesh_virtual_node" "servicea" {
	name = "servicea"
	mesh_name = var.appmesh_id
	mesh_owner = var.mesh_account_number

	spec {
		backend {
	      virtual_service {
	        virtual_service_name = "serviceb.simpleapp.mesh.local"
	      }
	    }

	    listener {
	      timeout {
	      	http {
	      		per_request {
	      			unit = "s"
	      			value = 120
	      		}

	      		idle {
	      			unit = "s"
	      			value = 60
	      		}
	      	}
	      }

	      port_mapping {
	        port     = 8080
	        protocol = "http"
	      }

	      health_check {
	        protocol            = "http"
	        path                = "/health"
	        healthy_threshold   = 2
	        unhealthy_threshold = 2
	        timeout_millis      = 2000
	        interval_millis     = 5000
	        port     			= 8080
	      }
	    }

	    service_discovery {
			aws_cloud_map {        
	        	service_name   = "servicea"
	        	namespace_name = aws_service_discovery_http_namespace.example.name
	      	}
	    }
	}
}

resource "aws_appmesh_virtual_service" "servicea" {
  name      = "servicea.simpleapp.mesh.local"
  mesh_name = var.appmesh_id
  mesh_owner = var.mesh_account_number

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.servicea.name
      }
    }
  }
}
