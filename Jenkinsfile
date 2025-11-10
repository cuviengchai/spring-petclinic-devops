pipeline {
    agent any

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

        stage('View Project Structure') {
            steps {
                echo 'Displaying project structure...'
                sh 'ls -la'
                sh 'pwd'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Spring Boot base image with Java 21...'
                    sh 'docker build -t spring-base .'
                }
            }
        }

        stage('Build Application') {
            steps {
                script {
                    echo 'Building application in container...'
                    sh '''
                        docker run --rm \
                            -v "${WORKSPACE}":/app \
                            -w /app \
                            -e JAVA_HOME=/opt/java/openjdk \
                            spring-base \
                            /bin/bash -c "./gradlew clean build --no-daemon --no-build-cache -x checkstyleNohttp"
                    '''
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                script {
                    echo 'Archiving build artifacts...'
                    archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
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
