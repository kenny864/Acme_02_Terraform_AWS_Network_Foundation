# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating VPC
resource "aws_vpc" "main" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  tags                  = {
                          Name = "main_vpc"
                        }
}

# subnets variable
variable "subnets" {
  type = map(object({
    cidr = string
    az_index = number
    is_public = bool
    route_table = string
  }))

  default = {
    "web_a" = {cidr = "10.0.1.0/24", az_index = 0, is_public = true,  route_table = "web"}
    "web_b" = {cidr = "10.0.2.0/24", az_index = 1, is_public = true,  route_table = "web"}
    "app_a" = {cidr = "10.0.3.0/24", az_index = 0, is_public = false, route_table = "app"}
    "app_b" = {cidr = "10.0.4.0/24", az_index = 1, is_public = false, route_table = "app"}
    "db_a"  = {cidr = "10.0.5.0/24", az_index = 0, is_public = false, route_table = "db" }
    "db_b"  = {cidr = "10.0.6.0/24", az_index = 1, is_public = false, route_table = "db" }
  }
}

# Creating subnets
resource "aws_subnet" "network" {
  for_each                = var.subnets
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = each.value.is_public
  cidr_block = each.value.cidr
  tags                    = {
                            Name = "subnet_${each.key}"
                          }
}