################################################################
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
security_group_id   = aws_security_group.alb_sg.id
cidr_ipv4           = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# ALB allow https traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# ALB allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "alb_allow_all_traffic" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

################################################################
# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allows traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  tags        = {
                Name = "app_sg"
              }
}

# App allows http traffic from alb
resource "aws_vpc_security_group_ingress_rule" "app_allow_alb_http" {
  security_group_id             = aws_security_group.app_sg.id
  referenced_security_group_id  = aws_security_group.alb_sg.id
  from_port                     = 80
  ip_protocol                   = "tcp"
  to_port                       = 80
  
}

# App allows https traffic from alb
resource "aws_vpc_security_group_ingress_rule" "app_allow_alb_https" {
  security_group_id             = aws_security_group.app_sg.id
  referenced_security_group_id  = aws_security_group.alb_sg.id
  from_port                     = 443
  ip_protocol                   = "tcp"
  to_port                       = 443
}

# App allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "app_allow_all_traffic" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

################################################################
# DB Security Group
resource "aws_security_group" "db_sg" {
  name          = "db_sg"
  description   = "Allows MySQL traffic only from the application tier"
  vpc_id        = aws_vpc.main.id

  tags          = {
                    Name = "db_sg"
                }
}

# DB allows traffic from the app-sg
resource "aws_vpc_security_group_ingress_rule" "db_allow_app" {
  security_group_id             = aws_security_group.db_sg.id
  referenced_security_group_id  = aws_security_group.app_sg.id
  from_port                     = 3306
  ip_protocol                   = "tcp"
  to_port                       = 3306
}

# App allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "db_allow_all_traffic" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}