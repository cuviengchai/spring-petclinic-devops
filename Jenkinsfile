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
                            -Dsonar.token=squ_8c3dedd2826e7e23b988bdeeb75d9e543155a53e
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