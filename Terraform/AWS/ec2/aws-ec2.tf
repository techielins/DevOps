
resource "aws_instance" "myInstance" {
  ami                           = var.aws_ami
  instance_type                 = var.instance_type
  availability_zone             = var.aws_az
  #key_name                      = var.aws_key_name
  subnet_id                     = aws_subnet.vnet01-priv-subnet1.id
  ebs_optimized                 = false
  hibernation                   = false
  private_ip                    = var.private_ip
  associate_public_ip_address   = true
  vpc_security_group_ids        = [aws_security_group.vnet01-sg1.id]
  monitoring                    = false
  secondary_private_ips         = []
  security_groups               = []
  source_dest_check             = true 
  tags = {
    Name = "linuxhost01"
  }
  
  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", true)
    }
  }
  
  root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 100
        volume_size           = 10
    }

    timeouts {}
}
