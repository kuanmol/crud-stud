# Use a base image with Java 17
FROM openjdk:11-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the generated JAR file into the container
COPY target/studentcrud-0.0.1-SNAPSHOT.jar /app/studentcrud.jar

# Run the JAR file
ENTRYPOINT ["java", "-jar", "/app/studentcrud.jar"]
