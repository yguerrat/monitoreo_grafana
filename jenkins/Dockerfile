# Jenkins ejecuta el pipeline dentro de Docker con Git y Python.
FROM jenkins/jenkins:lts-jdk21
USER root
RUN apt-get update && apt-get install -y --no-install-recommends python3 git curl \
    && rm -rf /var/lib/apt/lists/*
USER jenkins
