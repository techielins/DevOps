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

resource "random_string" "random" {
  count            = 2
  length           = 4
  special          = false
  upper            = false
  
}



# Start a container
resource "docker_container" "nodered_container" {
  count = 2
  name  = join("-",["nodered",random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
  
  ports {
    internal = 1880
    #external = 1880
  }
}


output "container_ip_addr1" {
  value       = join(":",[docker_container.nodered_container[0].ip_address,docker_container.nodered_container[0].ports[0].external])
  description = "The private IP address and External port of the container1."
}

output "container_name1" {
  value       = docker_container.nodered_container[0].name
  description = "The name of the container1."
  
}

output "container_ip_addr2" {
  value       = join(":",[docker_container.nodered_container[1].ip_address,docker_container.nodered_container[1].ports[0].external])
  description = "The private IP address and External port of the container2."
}

output "container_name2" {
  value       = docker_container.nodered_container[1].name
  description = "The name of the container2."
  
}
