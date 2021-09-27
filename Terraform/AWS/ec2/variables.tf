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

#### SUBNET INFO ####

variable "subnet_name" {
      default = "vnet01-priv1" 
      }

### SUBNET CIDR ####

variable "subnet_cidr_block" {
      default = "172.10.1.0/24"
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
        default = "t2.micro"
      }

variable "aws_ami" {
    default = "ami-0dc2d3e4c0f9ebd18"
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
    default = "EC2KeyPairs"
}

### AMI LIST ####

variable "instance_ami_id" {
        type = map

        default = {
        CENTOS8   = "ami-056d1e4814a97ac59"
        CENTOS7   = "ami-0d0db0aecada009c5"
        AMAZON_LINUX  = "ami-0947d2ba12ee1ff75"    
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
