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
resource "docker_container" "ubuntu" {
  name  = "nodered"
  image = docker_image.nodered_image.latest
  
  ports {
    internal = 1880
    external = 1880
  }
}
