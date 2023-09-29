FROM jenkins/jenkins:lts-jdk11
# Distributed Builds plugins
RUN jenkins-plugin-cli --plugins ssh-slaves

#Install GIT
RUN jenkins-plugin-cli --plugins git

# Artifacts
RUN jenkins-plugin-cli --plugins htmlpublisher

# UI
RUN jenkins-plugin-cli --plugins greenballs
RUN jenkins-plugin-cli --plugins simple-theme-plugin

# Scaling
RUN jenkins-plugin-cli --plugins kubernetes

VOLUME /var/jenkins_home

USER jenkins
