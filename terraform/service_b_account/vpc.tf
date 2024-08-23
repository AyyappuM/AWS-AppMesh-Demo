resource "aws_vpc" "example" {
  cidr_block = "${var.service_b_account_vpc_cidr_range}"
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "${var.service_b_account_subnet_cidr_range}"
  vpc_id = "${aws_vpc.example.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "example" {
  vpc_id = "${aws_vpc.example.id}"

  route {
    cidr_block = "${var.service_b_account_vpc_cidr_range}"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "192.168.0.0/24"
    gateway_id = var.transit_gateway_id
  }

  depends_on = [ "aws_ec2_transit_gateway_vpc_attachment.example" ]
}

# LINK ROUTE TABLE WITH THE SUBNET

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.example.id
}

# SECURITY GROUP

resource "aws_security_group" "load_balancer_sg" {
  name   = "service-b-alb-sg"
  vpc_id = "${aws_vpc.example.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name   = "service-b-ecs-tasks-sg"
  vpc_id = "${aws_vpc.example.id}"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.load_balancer_sg.id}"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}