### VPC DETAILS ###

resource "aws_vpc" "vnet01" { 
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

### SUBNET DETAILS ####

resource "aws_subnet" "vnet01-priv-subnet1" {
  vpc_id            = aws_vpc.vnet01.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.aws_az
  tags = {
    Name = var.subnet_name
    }
}

### INTERNET GATEWAY ####

resource "aws_internet_gateway" "vnet01_igw" {
    vpc_id   = aws_vpc.vnet01.id
    tags = {
      Name = var.igw_name
    }
}

### ROUTE TABLE ###

resource "aws_route_table" "vnet01_rt" {
    vpc_id  = aws_vpc.vnet01.id
    route  {
            cidr_block   = "0.0.0.0/0"
            gateway_id   = aws_internet_gateway.vnet01_igw.id
        }
    tags = {
      Name = var.rt_name
    }

}

#### ROUTE TABLE ASSOCIATION ####

resource "aws_route_table_association" "vnet01_rta" {
    route_table_id = aws_route_table.vnet01_rt.id
    subnet_id      = aws_subnet.vnet01-priv-subnet1.id
}



### SECURITY GROUP ###

resource "aws_security_group" "vnet01-sg1" {
  name          = "HTTP and SSH"
  vpc_id        = aws_vpc.vnet01.id
  description   = "SSH ,HTTP, and HTTPS"

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
    
    {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = "Inbound HTTP Rule"
            from_port        = 8080
            protocol         = "tcp"
            to_port          = 8080
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

