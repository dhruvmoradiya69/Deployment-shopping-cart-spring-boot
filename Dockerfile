# Use Maven 3.8.3 with OpenJDK 17 as the build stage
FROM maven:3.8.3-openjdk-17 AS build

# Set the working directory inside the container
WORKDIR /src

# Copy all project files to the working directory
COPY . /src

# Run Maven clean and package commands, skipping tests for faster build
RUN mvn clean package -DskipTests=true

# Use OpenJDK 17 with Alpine for the production image
FROM openjdk:17-alpine AS proud

# Copy the built JAR file from the build stage to the production image
COPY --from=build /src/target/*.jar /src/target/shopping.jar

# Expose port 5050 for the application to listen on
EXPOSE 8080

# Define the entry point to run the application
ENTRYPOINT [ "java", "-jar", "/src/target/shopping.jar" ]
