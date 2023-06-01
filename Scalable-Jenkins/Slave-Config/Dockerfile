FROM jenkins/inbound-agent:latest

USER root

# Install Git, Docker, and required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Install Maven
RUN curl -fsSL -o /tmp/apache-maven.tar.gz https://apache.osuosl.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \
    tar -xzf /tmp/apache-maven.tar.gz -C /opt && \
    rm /tmp/apache-maven.tar.gz

# Configure Maven environment variables
ENV MAVEN_HOME=/opt/apache-maven-3.6.3
ENV MAVEN_CONFIG="$HOME/.m2"

USER jenkins
