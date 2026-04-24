FROM maven:3.8.5-openjdk-17 AS build
COPY . /app
WORKDIR /app
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "/app.jar"]

FROM jenkins/jenkins:lts
USER root

# Install Ansible AND Docker CLI
RUN apt-get update && \
    apt-get install -y ansible docker.io && \
    rm -rf /var/lib/apt/lists/*

# Add jenkins user to the docker group
RUN usermod -aG docker jenkins

USER jenkins
