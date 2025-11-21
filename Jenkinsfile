pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000'
    }
    
    stages {
        stage('Setup Git') {
            steps {
                echo 'Configuring Git safe directory...'
                sh 'git config --global --add safe.directory "*"'
            }
        }

        stage('Checkout') {
            steps {
                echo 'Checking out Spring PetClinic source code...'
                git branch: 'develop', url: 'https://github.com/cuviengchai/spring-petclinic-devops.git'
            }
        }

        stage('Verify Environment') {
            steps {
                script {
                    echo "Checking Java version..."
                    sh 'java -version'
                    
                    echo "Checking Docker availability..."
                    sh 'docker --version || echo "Docker not available"'
                    
                    echo "Testing Docker connectivity..."
                    sh 'docker ps || echo "Cannot connect to Docker daemon"'
                    
                    echo "Checking Gradle..."
                    sh './gradlew --version'
                }
            }
        }

        stage('View Project Structure') {
            steps {
                echo 'Displaying project structure...'
                sh 'ls -la'
                sh 'pwd'
            }
        }

        stage('Build Application') {
            steps {
                sh './gradlew clean build --no-daemon --no-build-cache -x checkstyleNohttp'
            }
        }

        stage('Run Application') {
            steps {
                script {
                    echo 'Starting Spring Boot application in Docker...'
                    sh '''
                        # Stop any existing container
                        docker stop petclinic-app || true
                        docker rm petclinic-app || true
                        
                        # Find the jar file dynamically
                        JAR_FILE=$(find build/libs -name "*.jar" -not -path "*plain*" -type f | head -n 1)
                        echo "Found JAR file: $JAR_FILE"
                        
                        # Run the application in Docker container
                        docker run -d --name petclinic-app \\
                            -p 8000:8000 \\
                            -v "${WORKSPACE}":/app \\
                            -w /app \\
                            -e JAVA_HOME=/opt/java/openjdk \\
                            spring-base \\
                            java -jar "$JAR_FILE" --server.port=8000
                        
                        # Wait a bit for startup
                        sleep 10
                        
                        # Check if container is running
                        if docker ps | grep -q petclinic-app; then
                            echo "Application is running successfully in Docker"
                            docker logs petclinic-app | tail -10
                        else
                            echo "Application failed to start"
                            docker logs petclinic-app
                            exit 1
                        fi
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "Running SonarQube analysis..."
                    withSonarQubeEnv('SonarQube') {
                        echo "Test Injection: \${SONAR_TOKEN}"
                        sh """
                            ./gradlew sonar \
                            -Dsonar.projectKey=devops-team2 \
                            -Dsonar.projectName=devops-team2 \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.token=${SONAR_AUTH_TOKEN}
                        """
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script {
                    echo "Waiting for Quality Gate..."
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed'
        }
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}