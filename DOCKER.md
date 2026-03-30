# Docker Setup for Simple Java WebApp

This directory contains Docker configuration for building and running the Simple Java WebApp application.

## Files

- **Dockerfile**: Multi-stage Dockerfile that builds the application and runs it in a Tomcat container
- **docker-compose.yml**: Docker Compose configuration for easy container orchestration
- **.dockerignore**: Excludes unnecessary files from the Docker build context

## Building the Docker Image

### Using Docker CLI

```bash
# Build the image
docker build -t simple-java-webapp:1.0.0 .

# Run the container
docker run -p 8080:8080 simple-java-webapp:1.0.0
```

### Using Docker Compose

```bash
# Build and start the container
docker-compose up -d

# Stop the container
docker-compose down

# View logs
docker-compose logs -f simple-java-webapp
```

## Dockerfile Overview

The Dockerfile uses a **multi-stage build** approach:

### Stage 1: Builder
- Base Image: `maven:3.9-eclipse-temurin-17`
- Compiles and packages the Maven project
- Produces the executable JAR file

### Stage 2: Runtime
- Base Image: `tomcat:11-jdk21`
- Copies the built JAR from the builder stage
- Removes default Tomcat webapps
- Exposes port 8080
- Includes health check
- Sets JVM memory options

## Configuration

### Environment Variables

- `JAVA_OPTS`: JVM options (default: `-Xms128m -Xmx512m`)

### Port Mapping

- Container Port: 8080
- Host Port: 8080

### Health Check

- Interval: 30 seconds
- Timeout: 10 seconds
- Start Period: 5 seconds
- Retries: 3

## Accessing the Application

Once the container is running, access the application at:

```
http://localhost:8080/
```

## Dockerfile Best Practices Used

1. **Multi-stage builds**: Reduces final image size by separating build and runtime stages
2. **.dockerignore**: Excludes unnecessary files from the build context
3. **Health checks**: Monitors container health
4. **JVM memory limits**: Prevents memory issues in containerized environments
5. **Non-root user**: Tomcat runs as a non-root user (built into the Tomcat image)
6. **EXPOSE declaration**: Explicitly declares the port used

## Image Size Optimization

- Build stage uses Maven image with JDK 17
- Runtime stage uses lightweight Tomcat 11 with JDK 21
- Only the final JAR is copied to runtime stage
- Average final image size: ~550-650 MB

## Troubleshooting

### Container exits immediately

Check the logs:
```bash
docker logs <container-id>
```

### Port already in use

Change the port mapping in docker-compose.yml or use:
```bash
docker run -p 9090:8080 simple-java-webapp:1.0.0
```

### Slow startup

The first build may take several minutes as Maven dependencies are downloaded. Subsequent builds will be faster due to Docker layer caching.
