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

# Start a container
resource "docker_container" "nodered_container" {
  name  = "nodered"
  image = docker_image.nodered_image.latest
  
  ports {
    internal = 1880
    external = 1880
  }
}

output "container_ip_addr" {
  value       = join(":", [docker_container.nodered_container.ip_address,docker_container.nodered_container.ports[0].external])
  description = "The private IP address and External port of the container."
}

output "container_name" {
  value       = docker_container.nodered_container.name
  description = "The name of the container."
}
