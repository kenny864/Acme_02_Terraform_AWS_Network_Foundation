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
  allocation_id     = aws_eip.regional_nat_eip.id
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
    gateway_id = aws_internet_gateway.internet_gateway.id
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
    nat_gateway_id = aws_nat_gateway.regional_nat_gateway.id
  }

  tags = {
    Name = "app_route_table"
  }
}

# Associate web_subnets with web_route_table
resource "aws_route_table_association" "web_route_associations" {
  for_each        = { for key, val in var.subnets: key => val if val.route_table == "web"}

  subnet_id       = aws_subnet.network[each.key].id
  
  route_table_id  = aws_route_table.web_route_table.id

}

# Associate app_subnets with app_route_table
resource "aws_route_table_association" "app_route_association" {
  for_each        = { for key, val in var.subnets: key => val if val.route_table == "app"}

  subnet_id       = aws_subnet.network[each.key].id

  route_table_id  = aws_route_table.app_route_table.id
}