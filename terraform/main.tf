variable "mesh_account_number" {
  type    = string
}

variable "region" {
  type    = string
}

variable "service_a_account_number" {
  type    = string
}

variable "service_a_account_profile" {
  type    = string
}

variable "service_a_account_vpc_cidr_range" {
  type    = string
  default = "192.168.0.0/25"
}

variable "service_a_account_subnet_cidr_range" {
  type    = string
}

variable "service_b_account_number" {
  type    = string
}

variable "service_b_account_profile" {
  type    = string
}

variable "service_b_account_vpc_cidr_range" {
  type    = string
  default = "192.168.0.128/25"
}

variable "service_b_account_subnet_cidr_range" {
  type    = string
}

provider "aws" {
  alias   = "mesh_account"
  region  = "ap-south-1"
  profile = "a1"
}

provider "aws" {
  alias   = "service_a_account"
  region  = "ap-south-1"
  profile = "a2"
}

provider "aws" {
  alias   = "service_b_account"
  region  = "ap-south-1"
  profile = "a3"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
