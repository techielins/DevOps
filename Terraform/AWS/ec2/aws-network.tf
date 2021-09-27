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

#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  #ingress {
  #  from_port   = 22
  #  to_port     = 22
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  ingress     = [
    
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "Inbound SSH Rule"
            from_port        = 22
            protocol         = "tcp"
            security_groups  = []
            to_port          = 22
             prefix_list_ids  = null  # (Optional) List of prefix list IDs.
            ipv6_cidr_blocks = null  #(Optional) List of IPv6 CIDR blocks.
            security_groups  = null   #(Optional) List of security group Group Names if using EC2-Classic or Group IDs if using a VPC.
            self             = false #(Optional, default set to false) If true, the security group will be added as a source to this ingress rule.      
        }, 

        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "Inbound HTTP Rule"
            from_port        = 80
            protocol         = "tcp"
            to_port          = 80
            prefix_list_ids  = null  #(Optional) List of prefix list IDs.
            ipv6_cidr_blocks = null  #(Optional) List of IPv6 CIDR blocks.
            security_groups  = null   #(Optional) List of security group Group Names if using EC2-Classic or Group IDs if using a VPC.
            self             = false #(Optional, default set to false) If true, the security group will be added as a source to this ingress rule.
        },
    
    {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "Inbound HTTPS Rule"
            from_port        = 443
            protocol         = "tcp"
            to_port          = 443
            prefix_list_ids  = null  #(Optional) List of prefix list IDs.
            ipv6_cidr_blocks = null  #(Optional) List of IPv6 CIDR blocks.
            security_groups  = null   #(Optional) List of security group Group Names if using EC2-Classic or Group IDs if using a VPC.
            self             = false #(Optional, default set to false) If true, the security group will be added as a source to this ingress rule.
            
        },
   ]
   

egress {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "default egress"
            from_port        = 0
            protocol         = "-1"
            to_port          = 0
            self             = false
        }
  
    tags = {
    Name = var.sg_name
    } 
    timeouts {}
}

