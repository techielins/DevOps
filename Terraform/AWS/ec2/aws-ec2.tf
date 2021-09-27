
resource "aws_instance" "myInstance" {
  ami                           = var.aws_ami
  instance_type                 = var.instance_type
  availability_zone             = var.aws_az
  #key_name                      = var.aws_key_name
  subnet_id                     = aws_subnet.vnet01-priv1.id
  ebs_optimized                 = false
  hibernation                   = false
  private_ip                    = var.private_ip
  monitoring                    = false
  secondary_private_ips         = []
  security_groups               = []
  source_dest_check             = true 
  tags = {
    Name = "linuxhost01"
  }
  
  
  root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 8
    }

    timeouts {}
}
