pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }

    environment {
        // Maven
        MAVEN_HOME = '/usr/bin/mvn'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk'
        
        // Docker
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'simple-java-webapp'
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE_LATEST = 'latest'
        
        // SonarCloud
        SONAR_HOST_URL = credentials('sonarcloud-host-url')
        SONAR_LOGIN = credentials('sonarcloud-token')
        SONAR_PROJECT_KEY = 'simple-java-webapp'
        SONAR_ORGANIZATION = 'your-sonarcloud-org'
        
        // Application
        APP_NAME = 'Simple Java WebApp'
        APP_VERSION = '1.0.0'
    }

    parameters {
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running tests')
        booleanParam(name: 'SKIP_SONAR', defaultValue: false, description: 'Skip SonarCloud analysis')
        booleanParam(name: 'PUSH_DOCKER', defaultValue: false, description: 'Push Docker image to registry')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "========== Checking out from SCM =========="
                }
                checkout scm
                script {
                    echo "Repository: ${GIT_URL}"
                    echo "Branch: ${GIT_BRANCH}"
                    echo "Commit: ${GIT_COMMIT}"
                }
            }
        }

        stage('Prepare') {
            steps {
                script {
                    echo "========== Preparing Environment =========="
                    echo "Java Version:"
                    sh 'java -version'
                    echo "Maven Version:"
                    sh 'mvn -v'
                    echo "Docker Version:"
                    sh 'docker --version'
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "========== Building Maven Project =========="
                    dir('app') {
                        sh '''
                            mvn clean compile -DskipTests \
                                -Dmaven.test.skip=true \
                                -X
                        '''
                    }
                }
            }
            post {
                success {
                    echo "✓ Build successful"
                }
                failure {
                    echo "✗ Build failed"
                    error("Maven build failed")
                }
            }
        }

        stage('Test') {
            when {
                expression {
                    return !params.SKIP_TESTS
                }
            }
            steps {
                script {
                    echo "========== Running Tests =========="
                    dir('app') {
                        sh '''
                            mvn test \
                                -Dmaven.test.failure.ignore=false \
                                -Dsurefire.reportsDirectory=target/surefire-reports
                        '''
                    }
                }
            }
            post {
                always {
                    echo "========== Publishing Test Results =========="
                    junit 'app/target/surefire-reports/*.xml'
                    script {
                        def testResults = junit 'app/target/surefire-reports/*.xml'
                        echo "Tests run: ${testResults.totalCount}"
                        echo "Failures: ${testResults.failureCount}"
                        echo "Skipped: ${testResults.skipCount}"
                    }
                }
            }
        }

        stage('Code Quality Analysis - SonarCloud') {
            when {
                expression {
                    return !params.SKIP_SONAR
                }
            }
            steps {
                script {
                    echo "========== Running SonarCloud Analysis =========="
                    dir('app') {
                        sh '''
                            mvn clean verify sonar:sonar \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.organization=${SONAR_ORGANIZATION} \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=${SONAR_LOGIN} \
                                -Dsonar.sources=src/main/java \
                                -Dsonar.tests=src/test/java \
                                -Dsonar.java.binaries=target/classes \
                                -Dsonar.java.test.binaries=target/test-classes \
                                -Dsonar.exclusions=**/*.java.bak
                        '''
                    }
                }
            }
            post {
                success {
                    echo "✓ SonarCloud analysis completed"
                }
                failure {
                    echo "⚠ SonarCloud analysis failed (non-blocking)"
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    echo "========== Packaging Application =========="
                    dir('app') {
                        sh '''
                            mvn package -DskipTests \
                                -Dmaven.test.skip=true
                        '''
                    }
                }
            }
            post {
                success {
                    script {
                        echo "========== Creating Build Artifacts =========="
                        archiveArtifacts artifacts: 'app/target/simple-java-webapp-*.jar', 
                                          allowEmptyArchive: false,
                                          fingerprint: true
                    }
                }
                failure {
                    error("Maven package failed")
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "========== Building Docker Image =========="
                    sh '''
                        docker build \
                            --tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
                            --tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_LATEST} \
                            --label "build.number=${BUILD_NUMBER}" \
                            --label "git.commit=${GIT_COMMIT}" \
                            --label "git.branch=${GIT_BRANCH}" \
                            --label "build.timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
                            .
                    '''
                }
            }
            post {
                success {
                    script {
                        echo "========== Docker Image Information =========="
                        sh '''
                            docker images ${DOCKER_IMAGE_NAME}
                            docker inspect ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        '''
                    }
                }
                failure {
                    error("Docker image build failed")
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    echo "========== Testing Docker Image =========="
                    sh '''
                        # Start container
                        CONTAINER_ID=$(docker run -d -p 8080:8080 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG})
                        echo "Started container: $CONTAINER_ID"
                        
                        # Wait for container to start
                        sleep 10
                        
                        # Test endpoint
                        echo "Testing application endpoint..."
                        curl -f http://localhost:8080/ || exit 1
                        
                        # Check if response contains expected message
                        curl -s http://localhost:8080/ | grep -q "hello from Java" || exit 1
                        
                        # Stop container
                        docker stop $CONTAINER_ID
                        docker rm $CONTAINER_ID
                        
                        echo "✓ Docker image test passed"
                    '''
                }
            }
            post {
                always {
                    script {
                        // Cleanup if test failed
                        sh 'docker ps -aq --filter "ancestor=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" | xargs -r docker rm -f || true'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            when {
                expression {
                    return params.PUSH_DOCKER && currentBuild.result == null
                }
            }
            steps {
                script {
                    echo "========== Pushing Docker Image to Registry =========="
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                            docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_LATEST} ${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_LATEST}
                            docker push ${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                            docker push ${DOCKER_USER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_LATEST}
                            docker logout
                        '''
                    }
                }
            }
            post {
                success {
                    echo "✓ Docker image pushed successfully"
                }
                failure {
                    echo "⚠ Docker push failed (non-blocking)"
                }
            }
        }

        stage('Generate Reports') {
            when {
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    echo "========== Generating Build Reports =========="
                    dir('app') {
                        sh '''
                            # Copy test reports
                            mkdir -p ${WORKSPACE}/reports/tests
                            cp -r target/surefire-reports/* ${WORKSPACE}/reports/tests/ || true
                            
                            # Copy code coverage if available
                            mkdir -p ${WORKSPACE}/reports/coverage
                            cp -r target/site/jacoco/* ${WORKSPACE}/reports/coverage/ || true
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "========== Post-Build Actions =========="
                
                // Cleanup Docker resources
                sh '''
                    # Remove dangling Docker images
                    docker image prune -f --filter "dangling=true" || true
                '''
            }
        }
        
        success {
            script {
                echo "========== BUILD SUCCESSFUL =========="
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Build URL: ${BUILD_URL}"
                
                // Send success notification
                emailext (
                    subject: "✓ Build #${BUILD_NUMBER} Successful - ${APP_NAME}",
                    body: """
                        Build Summary:
                        - Build: #${BUILD_NUMBER}
                        - Status: SUCCESS
                        - Application: ${APP_NAME}
                        - Version: ${APP_VERSION}
                        - Duration: ${currentBuild.durationString}
                        
                        Docker Image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                        
                        Build Details: ${BUILD_URL}
                    """,
                    to: '${DEFAULT_RECIPIENTS}',
                    mimeType: 'text/html'
                )
            }
        }
        
        failure {
            script {
                echo "========== BUILD FAILED =========="
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Build URL: ${BUILD_URL}"
                
                // Send failure notification
                emailext (
                    subject: "✗ Build #${BUILD_NUMBER} Failed - ${APP_NAME}",
                    body: """
                        Build Summary:
                        - Build: #${BUILD_NUMBER}
                        - Status: FAILURE
                        - Application: ${APP_NAME}
                        - Version: ${APP_VERSION}
                        - Duration: ${currentBuild.durationString}
                        
                        Build Details: ${BUILD_URL}
                        Console Output: ${BUILD_URL}console
                    """,
                    to: '${DEFAULT_RECIPIENTS}',
                    mimeType: 'text/html'
                )
            }
        }
        
        unstable {
            script {
                echo "========== BUILD UNSTABLE =========="
                emailext (
                    subject: "⚠ Build #${BUILD_NUMBER} Unstable - ${APP_NAME}",
                    body: """
                        Build Summary:
                        - Build: #${BUILD_NUMBER}
                        - Status: UNSTABLE
                        - Application: ${APP_NAME}
                        - Duration: ${currentBuild.durationString}
                        
                        Build Details: ${BUILD_URL}
                    """,
                    to: '${DEFAULT_RECIPIENTS}',
                    mimeType: 'text/html'
                )
            }
        }
        
        cleanup {
            // Clean workspace if needed
            // cleanWs()
            echo "Pipeline execution completed"
        }
    }
}
