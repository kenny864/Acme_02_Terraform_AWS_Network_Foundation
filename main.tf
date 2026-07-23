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
  tags                    = {
                            Name = "subnet_{each.key}"
                          }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id  = aws_vpc.main.id
  tags    = {
            Name = "internet_gateway"
          }
}

# Elastic IP
resource "aws_eip" "regional_nat_eip" {
  domain      = "vpc"
  depends_on  = [aws_internet_gateway.internet_gateway]
  tags        = {
                  Name = "regional_nat_eip"
                }
}

# NAT Gateway
resource "aws_nat_gateway" "regional_nat_gateway" {
  allocation_id     = aws_eip.regional_nat_eip
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
  tags              = {
                      Name = "regional_nat_gateway"
                    }
}

# Web Route Table
resource "aws_route_table" "web_route_table" {
  vpc_id  = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway
  }

  tags = {
    Name = "web_route_table"
  }
}

# App Route Table
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "app_route_table"
  }
}

# Associate web_subnets with web_route_table
resource "aws_route_table_association" "web_route_associations" {
  for_each        = { for key, val in var.subnets: key => val if val.route_table == "web"}

  subnet_id       = aws_subnet.network[each.key].id
  
  route_table_id  = aws_route_table.web_route_table

}

# Associate app_subnets with app_route_table
resource "aws_route_table_association" "app_route_association" {
  for_each        = { for key, val in var.subnets: key => val if val.route_table == "app"}

  subnet_id       = aws_subnet.network[each.key].id

  route_table_id  = aws_route_table.app_route_table
}

# ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allows alb HTTP/HTTPS traffic from the Internet"
  vpc_id      = aws_vpc.main.id

  tags        = {
                Name = "alb_sg"
              }
}

# ALB allows http traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
security_group_id   = aws_security_group.alb_sg
cidr_ipv4           = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# ALB allow https traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.alb_sg
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# ALB allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic" {
  security_group_id = aws_security_group.alb_sg
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allows traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  tags        = {
                Name = "app_sg"
              }
}

# App allows http traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "app_allow_http" {
  security_group_id             = aws_security_group.app_sg
  referenced_security_group_id  = aws_security_group.alb_sg
  from_port                     = 80
  ip_protocol                   = "tcp"
  to_port                       = 80
  
}

# App allow https traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "app_allow_https" {
  security_group_id             = aws_security_group.app_sg
  referenced_security_group_id  = aws_security_group.alb_sg
  from_port                     = 443
  ip_protocol                   = "tcp"
  to_port                       = 443
}

# App allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "app_allow_all_traffic" {
  security_group_id = aws_security_group.app_sg
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# DB Security Group