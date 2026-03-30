# Multi-stage Dockerfile for Simple Java WebApp
# Stage 1: Build stage
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy the app directory (where pom.xml is located)
COPY app/ .

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage using Tomcat base image
FROM tomcat:11-jdk21

# Set working directory
WORKDIR /app

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built JAR from builder stage
COPY --from=builder /app/target/simple-java-webapp-1.0.0.jar /app/app.jar

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Set environment variables
ENV JAVA_OPTS="-Xms128m -Xmx512m"

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
