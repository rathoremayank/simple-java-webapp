# Jenkins Pipeline Quick Start Guide

## Prerequisites

- Jenkins server installed and running
- GitHub/GitLab account with repository access
- Docker Hub account (for pushing images)
- SonarCloud account (for code analysis)
- Jenkins plugins installed (see JENKINS.md)

## Step 1: Create Jenkins Credentials

### Option A: Using Jenkins UI (Recommended for first-time setup)

1. **Navigate to Credentials**
   - Jenkins Dashboard → Manage Credentials → System → Global credentials

2. **Add Docker Hub Credentials**
   - Click "Add Credentials"
   - Kind: `Username with password`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub access token
   - ID: `docker-hub-credentials`
   - Click "Create"

3. **Add SonarCloud Token**
   - Click "Add Credentials"
   - Kind: `Secret text`
   - Secret: Your SonarCloud token
   - ID: `sonarcloud-token`
   - Click "Create"

4. **Add SonarCloud Host URL**
   - Click "Add Credentials"
   - Kind: `Secret text`
   - Secret: `https://sonarcloud.io`
   - ID: `sonarcloud-host-url`
   - Click "Create"

### Option B: Using Jenkins CLI

```bash
# Set Jenkins environment
export JENKINS_URL=https://your-jenkins-server
export JENKINS_USER=your-username

# Run the setup script
bash scripts/setup-jenkins-credentials.sh
```

## Step 2: Update Jenkinsfile Configuration

Edit the `Jenkinsfile` and update:

```groovy
environment {
    // Update with your organization
    SONAR_ORGANIZATION = 'your-sonarcloud-org'
}

post {
    // Update with your email
    emailext (
        to: 'your-email@example.com',
        ...
    )
}
```

## Step 3: Create Jenkins Pipeline Job

1. **Create New Pipeline Job**
   - Jenkins Dashboard → New Item
   - Enter name: `simple-java-webapp`
   - Select "Pipeline"
   - Click "OK"

2. **Configure Pipeline**
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/your-username/simple-java-webapp`
   - Credentials: Select appropriate credentials
   - Branch: `*/main` or `*/master`
   - Script Path: `Jenkinsfile`

3. **Configure Build Triggers** (Optional)
   - Check "GitHub hook trigger for GITScm polling"
   - Or "Poll SCM" with schedule `H/15 * * * *` (every 15 minutes)

4. **Save**

## Step 4: Run Your First Build

### Via Jenkins UI
1. Go to your job: `simple-java-webapp`
2. Click "Build Now"
3. Monitor the build progress in the console output

### Via Jenkins Pipeline Parameters
1. Click "Build with Parameters"
2. Select options:
   - SKIP_TESTS: unchecked (run all tests)
   - SKIP_SONAR: unchecked (run code analysis)
   - PUSH_DOCKER: unchecked (don't push to registry)
3. Click "Build"

### Via Jenkins CLI
```bash
java -jar jenkins-cli.jar -s $JENKINS_URL build simple-java-webapp
```

## Build Results

After the build completes, you can view:

### Console Output
- Real-time build logs
- Compilation messages
- Test output

### Test Results
- Dashboard shows test summary
- Click "Test Result" for detailed report
- Test history chart shows trend

### Code Quality Analysis
- Link to SonarCloud dashboard
- Code coverage metrics
- Quality gate status

### Artifacts
- Built JAR file available for download
- Download link in build summary

### Docker Image
- Local image: `simple-java-webapp:${BUILD_NUMBER}`
- Can be pushed to Docker Hub with `PUSH_DOCKER=true`

## Common Build Scenarios

### Scenario 1: Quick Local Build (Development)
```
Parameters:
- SKIP_TESTS: false (run tests)
- SKIP_SONAR: true (skip analysis)
- PUSH_DOCKER: false (don't push)

Result: Fast feedback on code quality and tests
```

### Scenario 2: Full Build (Pre-Release)
```
Parameters:
- SKIP_TESTS: false (run tests)
- SKIP_SONAR: false (full analysis)
- PUSH_DOCKER: false (don't push yet)

Result: Complete quality check before release
```

### Scenario 3: Production Release
```
Parameters:
- SKIP_TESTS: false (run tests)
- SKIP_SONAR: false (full analysis)
- PUSH_DOCKER: true (push to registry)

Result: New Docker image pushed to Docker Hub
Image available as: {docker-username}/simple-java-webapp:{build-number}
```

## Monitoring Builds

### Dashboard View
1. Jenkins Dashboard → `simple-java-webapp`
2. View:
   - Latest build status (green/red)
   - Build history
   - Test trend graph
   - Build parameters used

### Email Notifications
- Success: Detailed build summary
- Failure: Error details with console link
- Unstable: Warning details

### SonarCloud Integration
- Direct link to SonarCloud project
- Code coverage trends
- Quality gate assessment
- Security hotspots

## Troubleshooting

### Build Fails at Checkout
```
Error: Authentication failed
Solution: Check SCM credentials in Pipeline configuration
```

### Build Fails at Maven Compile
```
Error: Cannot find symbol
Solution: Check Java version matches pom.xml requirements
Fix: Update JAVA_HOME in Jenkinsfile environment
```

### Build Fails at Docker Build
```
Error: Docker daemon not accessible
Solution: Ensure Docker is running and Jenkins user has permissions
Fix: sudo usermod -aG docker jenkins
```

### Tests Fail
```
Solution: Check test output in console
Run locally: mvn test -DfailIfNoTests=false
Debug: Run individual test with mvn -Dit.test=TestClass test
```

### SonarCloud Analysis Fails
```
Error: Invalid token
Solution: Verify sonarcloud-token credential in Jenkins
Error: Invalid organization
Solution: Update SONAR_ORGANIZATION in Jenkinsfile
```

### Push to Docker Registry Fails
```
Error: Access denied
Solution: Check docker-hub-credentials are correct
Error: Image not found
Solution: Ensure Docker build completed successfully
```

## Advanced Configurations

### Enable Parallel Testing
In Jenkinsfile, update Maven command:
```groovy
sh 'mvn test -T 1C'  // Test with 1 thread per core
```

### Skip Stages Based on Branch
```groovy
stage('Push Docker Image') {
    when {
        branch 'main'
    }
    // Only push if on main branch
}
```

### Advanced SonarCloud Configuration
```groovy
environment {
    SONAR_EXCLUSIONS='**/*Test.java,**/config/**'
}
```

### Custom Email Recipients
```groovy
emailext (
    to: 'dev-team@example.com',
    recipientProviders: [developers(), commiters()],
    // Automatically includes commit authors and developers
)
```

## Maintenance

### Regular Tasks
- Update Jenkins plugins monthly
- Review and update credentials (tokens expire)
- Monitor build logs for warnings
- Prune old build artifacts
- Monitor Jenkins disk usage

### Cleanup Old Builds
In job configuration:
- Discard old builds
- Keep last 10 successful builds
- Keep artifacts for last 5 builds

## Support & Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Pipeline Syntax](https://jenkins.io/doc/book/pipeline/syntax/)
- [Docker Documentation](https://docs.docker.com/)
- [SonarCloud Documentation](https://docs.sonarcloud.io/)
- [Maven Documentation](https://maven.apache.org/guides/)

## Next Steps

1. ✅ Set up credentials
2. ✅ Create Pipeline job
3. ✅ Run first build
4. ✅ Monitor build results
5. Configure build triggers (webhooks)
6. Set up email notifications
7. Configure status checks in GitHub/GitLab
8. Set up production deployment stages
