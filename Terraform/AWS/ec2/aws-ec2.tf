resource "aws_vpc" "my_vpc" { 
  cidr_block = var.vpc_cidr_block
}
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.vpc_cidr_block
  availability_zone = var.aws_az
}
resource "aws_security_group" "my_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.my_vpc.id

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
}
resource "aws_instance" "myInstance" {
  ami           = var.aws_ami
  instance_type = "t2.micro"
  key_name      = var.aws_key_name
  subnet_id     = aws_subnet.my_subnet.id

  tags = {
    Name = "linuxhost01"
  }
}
