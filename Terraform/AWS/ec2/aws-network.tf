### VPC DETAILS ###

resource "aws_vpc" "vnet01" { 
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

### SUBNET DETAILS ####

resource "aws_subnet" "vnet01-priv1" {
  vpc_id            = aws_vpc.vnet01.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.aws_az
  tags = {
    Name = var.subnet_name
    }
}

### SECURITY GROUP ###

resource "aws_security_group" "vnet01-sg1" {
  name          = "HTTP and SSH"
  vpc_id        = aws_vpc.vnet01.id
  description   = "SSH ,HTTP, and HTTPS"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  timeouts {}
}
