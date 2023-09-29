## Docker Containers as Build Agents/Slaves
This article guides you to set up Jenkins build inside a Docker container using Docker-based Jenkins build agents.
The first thing we should do is set up a docker host. Jenkins server will connect to this host for spinning up the build agent containers. Jenkins master connects to the docker host using REST APIs. 
So we need to enable the remote API for our docker host.
Make sure the following ports are enabled in your server firewall to accept connections from Jenkins master.


| Docker Remote API port | 4243 |
| ---   | --- |
| Docker Hostport Range | 32768 to 60999   |

32768 to 60999 is used by Docker to assign a host port for Jenkins to connect to the container. Without this connection, the build slave would go in a pending state.

Install Docker, once done Log in to the server and open the docker service file /lib/systemd/system/docker.service. Search for ExecStart and replace that line with the following.
```
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock
```
Reload and restart docker service.

Validate API by executing the following curl commands. 
```
curl http://localhost:4243/version
```
Once you enabled and tested the API, you can now start building the docker slave image.

## Configure Jenkins Server With Docker Plugin

Step 1: Head over to Jenkins Dashboard –> Manage Jenkins –> Manage Plugins.

Step 2: Under the Available tab, search for “Docker” and install the docker cloud plugin and restart Jenkins.

Step 3: Once installed, head over to Jenkins Dashboard –> Manage Jenkins –>Configure system.

Step 4: Under “Configure System“, if you scroll down, there will be a section named “cloud” at the last. There you can fill out the docker host parameters for spinning up the slaves.

Step 5: Under docker, you need to fill out the details as below.

Replace “Docker URI” with your docker host IP. For example, tcp://192.168.1.30:4243 You can use the “Test connection” to test if Jenkins is able to connect to the Docker host.

Step 6: Now, from “Docker Agent Template” dropdown, click the “Add Docker template” and fill in the details based on the explanation and the image given below and save the configuration.




	
