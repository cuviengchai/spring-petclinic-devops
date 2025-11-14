pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out Spring PetClinic source code...'
<<<<<<< Updated upstream
                checkout scm
            }
        }

        stage('View Project Structure') {
            steps {
                echo 'Displaying project structure...'
                sh 'ls -la'
            }
        }
    }
}
=======
                git branch: 'develop', url: 'https://github.com/cuviengchai/spring-petclinic-devops.git'
            }
        }

        stage('View Project Structure') {
            steps {
                echo 'Displaying project structure...'
                sh 'ls -la'
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building Spring PetClinic application...'
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Run Application Container') {
            steps {
                echo 'Running Spring PetClinic container for testing...'
                sh '''
                    docker network create devops || true

                    # Stop any existing container if running
                    docker stop petclinic || true
                    docker rm petclinic || true

                    # Build and run the PetClinic app on port 8085 (avoiding Jenkins port 8080)
                    docker build -t petclinic:latest .
                    docker run -d --name petclinic --network devops -p 8085:8080 petclinic:latest
                    
                    # Wait for application to start
                    echo 'Waiting for application to start...'
                    sleep 10
                '''
            }
        }

        stage('OWASP ZAP Scan') {
            steps {
                echo 'Running OWASP ZAP baseline scan...'
                sh '''
                    mkdir -p zap-reports
                    docker run --rm \
                        --network devops \
                        -v "$PWD/zap-reports:/zap/wrk" \
                        ghcr.io/zaproxy/zaproxy:stable \
                        zap-baseline.py \
                            -t http://petclinic:8080 \
                            -r zap-report.html \
                            -m 5
                '''
            }
            post {
                always {
                    publishHTML(target: [
                        allowMissing: false,
                        keepAll: true,
                        reportDir: 'zap-reports',
                        reportFiles: 'zap-report.html',
                        reportName: 'OWASP ZAP Report'
                    ])
                    archiveArtifacts artifacts: 'zap-reports/*', fingerprint: true
                }
            }
        }

        stage('Cleanup') {
            steps {
                echo 'Cleaning up running containers...'
                sh '''
                    docker stop petclinic || true
                    docker rm petclinic || true
                '''
            }
        }
    }

    post {
        always {
            echo 'DevOps Pipeline Finished Successfully.'
        }
    }
}
>>>>>>> Stashed changes
