# Jenkins Pipeline Setup for Simple Java WebApp

This Jenkinsfile defines a comprehensive CI/CD pipeline for building, testing, analyzing, and containerizing the Simple Java WebApp application.

## Pipeline Stages

### 1. **Checkout**
- Checks out source code from SCM (Git)
- Logs repository, branch, and commit information

### 2. **Prepare**
- Verifies Java, Maven, and Docker versions
- Ensures all required tools are available

### 3. **Build**
- Compiles the Maven project
- Runs `mvn clean compile`
- Skips tests in this stage

### 4. **Test**
- Executes unit and integration tests
- Publishes test results to Jenkins
- Can be skipped with `SKIP_TESTS` parameter
- Uses JUnit plugin for result reporting

### 5. **Code Quality Analysis - SonarCloud**
- Performs static code analysis using SonarCloud
- Analyzes code coverage and quality metrics
- Can be skipped with `SKIP_SONAR` parameter
- Sends results to SonarCloud dashboard

### 6. **Package**
- Packages the application as a JAR file
- Archives build artifacts
- Fingerprints artifacts for tracking

### 7. **Build Docker Image**
- Builds multi-stage Docker image
- Tags image with build number and latest
- Applies metadata labels (build number, git commit, branch, timestamp)

### 8. **Test Docker Image**
- Starts the Docker container
- Tests the application endpoint
- Verifies the "hello from Java" message
- Cleans up test container

### 9. **Push Docker Image**
- Pushes Docker image to registry (conditional)
- Uses Docker Hub credentials from Jenkins credentials store
- Only runs if `PUSH_DOCKER` parameter is true

### 10. **Generate Reports**
- Collects test and code coverage reports
- Copies reports to workspace for archival

## Prerequisites

### Jenkins Plugins Required
```
- Pipeline
- Git
- Maven Integration
- Docker Pipeline
- SonarQube Scanner
- Email Extension
- JUnit
- Credentials Binding
```

### Jenkins Credentials Setup

Create the following credentials in Jenkins:

1. **GitHub/GitLab Credentials** (if using private repo)
   - Type: Username with password or SSH key
   - Credential ID: `scm-credentials`

2. **Docker Hub Credentials**
   - Type: Username with password
   - Credential ID: `docker-hub-credentials`
   - Username: Docker Hub username
   - Password: Docker Hub access token

3. **SonarCloud Token**
   - Type: Secret text
   - Credential ID: `sonarcloud-token`
   - Secret: SonarCloud authentication token

4. **SonarCloud Host URL**
   - Type: Secret text
   - Credential ID: `sonarcloud-host-url`
   - Secret: `https://sonarcloud.io`

### Environment Configuration

Update the following in the `environment` section:

```groovy
// SonarCloud
SONAR_ORGANIZATION = 'your-sonarcloud-org'  // Replace with your org

// Mail
DEFAULT_RECIPIENTS = 'team@example.com'  // Replace with your email
```

## Pipeline Parameters

### `SKIP_TESTS`
- **Type**: Boolean
- **Default**: false
- **Description**: Skip running unit and integration tests

### `SKIP_SONAR`
- **Type**: Boolean
- **Default**: false
- **Description**: Skip SonarCloud code quality analysis

### `PUSH_DOCKER`
- **Type**: Boolean
- **Default**: false
- **Description**: Push Docker image to registry after successful build

## Usage Examples

### Standard Build (with tests and SonarCloud)
```
No parameters, run with all stages
```

### Quick Build (skip analysis)
```
Set: SKIP_TESTS=true, SKIP_SONAR=true
```

### Build and Push to Registry
```
Set: PUSH_DOCKER=true
(All tests and analysis will run first)
```

## Jenkins Configuration

### 1. Create New Pipeline Job

1. In Jenkins Dashboard, click "New Item"
2. Enter job name: `simple-java-webapp`
3. Select "Pipeline"
4. Click "OK"

### 2. Configure GitHub/SCM Connection

1. Go to "Pipeline" section
2. Select "Pipeline script from SCM"
3. Choose SCM: "Git"
4. Enter repository URL
5. Select credentials
6. Set branch: `*/main` or `*/master`
7. Set script path: `Jenkinsfile`

### 3. Email Configuration

In Jenkins system configuration:
1. Manage Jenkins → System
2. Email Notification section:
   - SMTP server: `smtp.gmail.com` (or your provider)
   - Default user email suffix: `@example.com`
   - Reply-To Address: `noreply@example.com`
3. Extended E-mail Plugin:
   - SMTP server: `smtp.gmail.com`
   - Default Recipients: `team@example.com`

### 4. SonarCloud Integration

1. Generate SonarCloud token at https://sonarcloud.io/account/security/
2. Create Jenkins credential with token
3. Create Jenkins credential with SonarCloud host URL
4. Update SONAR_ORGANIZATION in Jenkinsfile

## Build Notifications

Pipeline sends email notifications on:
- **Success**: Build completion with details
- **Failure**: Failed build with console output link
- **Unstable**: Tests or warnings triggered unstable state

## Docker Image Naming

### Image Tags
- `simple-java-webapp:${BUILD_NUMBER}` - Build number tag
- `simple-java-webapp:latest` - Latest successful build
- `${DOCKER_USER}/simple-java-webapp:${BUILD_NUMBER}` - Pushed to registry

## Artifacts

### Build Artifacts
- JAR file: `simple-java-webapp-1.0.0.jar`
- Stored in Jenkins artifact storage
- Available for download from build page

### Reports
- Test reports: `reports/tests/`
- Code coverage: `reports/coverage/`
- SonarCloud: https://sonarcloud.io

## Troubleshooting

### Build Fails at Maven Stage
```bash
# Trigger: Maven not found
Solution: Ensure Maven is installed on Jenkins agent
# Check: Jenkins → Manage Jenkins → Tools → Maven installations
```

### Docker Build Fails
```bash
# Trigger: Docker daemon not accessible
Solution: Ensure Docker is running and Jenkins user has permissions
# Check: sudo usermod -aG docker jenkins
```

### SonarCloud Analysis Fails
```bash
# Trigger: Invalid token or organization
Solution: Verify SonarCloud credentials in Jenkins
# Check: SonarCloud → Security → Tokens
```

### Push to Registry Fails
```bash
# Trigger: Docker Hub credentials invalid
Solution: Update Docker Hub credentials in Jenkins
# Check: Jenkins → Credentials → Update docker-hub-credentials
```

## Best Practices

1. **Run with tests enabled** - Catch errors early
2. **Enable SonarCloud analysis** - Maintain code quality
3. **Set up email notifications** - Stay informed of builds
4. **Use credential binding** - Never expose secrets
5. **Archive artifacts** - Enable rollback if needed
6. **Tag Docker images** - Include build metadata
7. **Test Docker images** - Verify before pushing

## Security Considerations

1. Store all credentials in Jenkins credential store
2. Never hardcode secrets in Jenkinsfile
3. Use credential binding for sensitive values
4. Limit Docker registry access
5. Regularly update plugin security patches
6. Use Jenkins agent labels for environment isolation
7. Enable audit logging for build activities

## Performance Tips

1. Use Maven caching: `.m2/repository` volume mount
2. Docker layer caching for faster builds
3. Parallel testing with Maven Surefire
4. Run SonarCloud analysis only on specific branches
5. Use Jenkins agent pools for resource management

## References

- [Jenkins Pipeline Syntax](https://jenkins.io/doc/book/pipeline/)
- [Docker Pipeline Plugin](https://plugins.jenkins.io/docker-workflow/)
- [SonarQube Scanner for Maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)
- [Email Extension Plugin](https://plugins.jenkins.io/email-ext/)
