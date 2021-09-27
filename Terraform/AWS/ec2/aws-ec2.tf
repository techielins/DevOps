
resource "aws_instance" "myInstance" {
  ami                           = var.aws_ami
  instance_type                 = "t2.micro"
  availability_zone             = var.aws_az
  key_name                      = var.aws_key_name
  subnet_id                     = aws_subnet.subnet_name.id
  ebs_optimized                 = false
  hibernation                   = false
  instance_type                 = var.instance_type
  private_ip                    = var.private_ip
  monitoring                    = false
  secondary_private_ips         = []
  security_groups               = []
  source_dest_check             = true 
  tags = {
    Name = "linuxhost01"
  }
  
  credit_specification {
        cpu_credits = "standard"
    }
  
  root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
    }

    timeouts {}
}
