terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "nodered_image" {
  name = "nodered/node-red:latest"
}

resource "random_string" "random1" {
  length           = 4
  special          = false
  upper             = false
  
}


resource "random_string" "random2" {
  length           = 4
  special          = false
  upper             = false
  
}


# Start a container
resource "docker_container" "nodered_container1" {
  name  = join("-",["nodered",random_string.random1.result])
  image = docker_image.nodered_image.latest
  
  ports {
    internal = 1880
    #external = 1880
  }
}

resource "docker_container" "nodered_container2" {
  name  = join("-",["nodered",random_string.random2.result])
  image = docker_image.nodered_image.latest
  
  ports {
    internal = 1880
    #external = 1880
  }
}

output "container_ip_addr1" {
  value       = join(":",[docker_container.nodered_container1.ip_address,docker_container.nodered_container1.ports[0].external])
  description = "The private IP address and External port of the container1."
}

output "container_name1" {
  value       = docker_container.nodered_container1.name
  description = "The name of the container1."
  
}

output "container_ip_addr2" {
  value       = join(":",[docker_container.nodered_container2.ip_address,docker_container.nodered_container2.ports[0].external])
  description = "The private IP address and External port of the container2."
}

output "container_name2" {
  value       = docker_container.nodered_container2.name
  description = "The name of the container2."
  
}

