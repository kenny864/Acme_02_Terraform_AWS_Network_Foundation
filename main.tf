# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

variable "subnets" {
  type = map(object({
    cidr = string
    az_index = number
    is_public = bool
  }))

  default = {
    "public_subnet_a" = {cidr = "10.0.1.0/24", az_index = 0, is_public = true}
    "public_subnet_b" = {cidr = "10.0.2.0/24", az_index = 1, is_public = true}
    "app_subnet_a"    = {cidr = "10.0.3.0/24", az_index = 0, is_public = false}
    "app_subnet_b"    = {cidr = "10.0.4.0/24", az_index = 1, is_public = false}
    "data_subnet_a"   = {cidr = "10.0.5.0/24", az_index = 0, is_public = false}
    "data_subnet_b"   = {cidr = "10.0.6.0/24", az_index = 1, is_public = false}
  }
}

# Creating subnets
resource "aws_subnet" "subnets" {
  for_each = var.subnets
  vpc_id    = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = each.value.is_public
  tags = {
    Name = each.key
  }
}

