# Creating VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets A
resource "aws_subnet" "public_zone_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available[0]
}

# Public Subnets B
resource "aws_subnet" "public_zone_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available[1]
}

