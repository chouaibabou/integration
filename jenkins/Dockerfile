FROM jenkins

USER root
RUN apt-get update \
      && apt-get install -y sudo vim nano curl\
           ant\
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# getting the docker-cli
# --- Attention: docker.sock needs to be mounted as volume in docker-compose.yml
# see: https://issues.jenkins-ci.org/browse/JENKINS-35025
# see: https://get.docker.com/builds/
# see: https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Custom+Build+Environment+Plugin#CloudBeesDockerCustomBuildEnvironmentPlugin-DockerinDocker
RUN curl -sSL -O https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && tar -xvzf docker-latest.tgz
RUN mv docker/* /usr/bin/

USER jenkins

# installing specific list of plugins. see: https://github.com/jenkinsci/docker#preinstalling-plugins
COPY jenk/plugins.txt /var/jenkins_home/plugins.txt
RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt

# Adding default Jenkins Jobs
#COPY jobs/crud.xml /usr/share/jenkins/ref/jobs/crud/config.xml
#COPY /var/lib/jenkins/jobs/*  /usr/share/jenkins/ref/jobs/
#
#############################################
## Configure Jenkins
#############################################

## Jenkins User, Config, ...
COPY jenk/config/ /usr/share/jenkins/ref/
COPY jenk/users/ /usr/share/jenkins/ref/users/

# tell Jenkins that no banner prompt for pipeline plugins is needed
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
