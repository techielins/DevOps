### AWS region ####

variable aws_region {
    default = "us-east-1"
}

### VPC Name ###

variable "vpc_name" {
    default = "vnet01"
    }

### VPC CIDR BLOCK ####

variable "vpc_cidr_block" {
      default = "172.10.0.0/16"
    }

#### IGW NAME INFO ####

variable "igw_name" {
      default = "vnet01_igw" 
      }

#### ROUTE TABLE NAME INFO ####

variable "rt_name" {
      default = "vnet01_rt" 
      }

#### SUBNET INFO ####

variable "subnet_name" {
      default = "vnet01-priv-subnet1" 
      }

### SUBNET CIDR ####

variable "subnet_cidr_block" {
      default = "172.10.1.0/24"
      }

### Security Group Name ####

variable "sg_name" {
      default = "web_sg" 
      }


### EC2 INSTANCE DETAILS ####

variable "instance_name" {
        default = "aws-ec2-instance1"
      }

variable "preserve_boot_volume" {
        default = false
      }

variable "boot_volume_size_in_gbs" {
        default = "10"
      }

variable "instance_type" {
        default = "t3a.medium"
      }

variable "aws_ami" {
    default = "ami-00068cd7555f543d5"
}

### STATIC PRIVATE IP ####
        
variable "private_ip" {
     default = "172.10.1.10"
      }

### AWS AVAILABILITY ZONE ###

variable "aws_az" {
    default = "us-east-1a"
}

### SSH KEY PAIRS ###

variable "aws_key_name" {
    default = "ec2_key"
}

### AMI LIST ####

variable "instance_ami_id" {
        type = map

        default = {
        CENTOS8   = "ami-056d1e4814a97ac59"
        CENTOS7   = "ami-0d0db0aecada009c5"
        AMAZON_LINUX  = "ami-00068cd7555f543d5"    
}
     } 

variable "OS" {
  description = "AMI Name"
  default       = "AMAZON_LINUX" 
}

### CPU COUNT ###

variable "instance_cpus" {
      default = 1
      }   

### NETWORK INTERFACE ###

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}


