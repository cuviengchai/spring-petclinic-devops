pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000'
        ANSIBLE_SSH_ARGS = "-o ControlMaster=no -o ControlPersist=0"
    }

    parameters {
        string(name: 'SOURCE_FILE', defaultValue: 'myfile.txt', description: 'File to copy')
        string(name: 'DEST_PATH', defaultValue: '/home/devops/Desktop/petclinic/myfile.txt', description: 'Destination path')
        string(name: 'TARGET_HOST', defaultValue: '192.168.64.8', description: 'Target VM IP')
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

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t spring-base .'
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
                        docker network create devops || true

                        # Find the jar file dynamically
                        JAR_FILE=$(find build/libs -name "*.jar" -not -path "*plain*" -type f | head -n 1)
                        echo "Found JAR file: $JAR_FILE"
                        
                        # Run the application in Docker container
                        docker run -d --name petclinic-app \\
                            --network devops \\
                            -p 8000:8000 \\
                            -v "${WORKSPACE}":/app \\
                            -w /app \\
                            -e JAVA_HOME=/opt/java/openjdk \\
                            spring-base \\
                            java -jar "$JAR_FILE" --server.port=8000
                        
                        # Wait a bit for startup
                        sleep 5
                        
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
                        sh """
                            ./gradlew sonar \
                            -Dsonar.projectKey=devops-team2 \
                            -Dsonar.projectName=devops-team2 \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.token=${SONAR_AUTH_TOKEN} \
                            --no-daemon
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

        stage('OWASP ZAP Scan') {
            steps {
                script {
                    echo 'Running OWASP ZAP baseline scan...'
                    sh '''
                        # Create and prepare directory
                        mkdir -p "$PWD/zap-reports"
                        chmod 777 "$PWD/zap-reports"
                        
                        echo "Running ZAP scan with XML output..."
                        docker run --rm \
                            --user root \
                            --network devops \
                            -v "$PWD/zap-reports:/zap/wrk:rw" \
                            ghcr.io/zaproxy/zaproxy:stable \
                            zap-baseline.py \
                                -t http://petclinic-app:8000 \
                                -x zap-report.xml \
                                -m 0 || true
                        
                        echo "Checking for XML report..."
                        ls -la "$PWD/zap-reports/"
                        
                        if [ -f "$PWD/zap-reports/zap-report.xml" ]; then
                            echo "SUCCESS: XML report generated"
                            
                            # Create a simple XSLT stylesheet
                            cat > "$PWD/zap-reports/transform.xsl" << 'XSLT_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>
<xsl:template match="/">
<html>
<head>
    <title>OWASP ZAP Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #333; border-bottom: 3px solid #d32f2f; padding-bottom: 10px; }
        h2 { color: #555; margin-top: 30px; background: #fff; padding: 15px; border-radius: 5px; }
        .summary { background: #fff; padding: 20px; margin: 20px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .alert { background: #fff; margin: 15px 0; padding: 15px; border-left: 4px solid #ff9800; border-radius: 3px; }
        .high { border-left-color: #d32f2f; }
        .medium { border-left-color: #ff9800; }
        .low { border-left-color: #ffc107; }
        .informational { border-left-color: #2196f3; }
        .alert-name { font-weight: bold; font-size: 18px; margin-bottom: 10px; color: #333; }
        .desc { margin: 10px 0; line-height: 1.6; }
        .url { color: #1976d2; word-break: break-all; margin: 5px 0; font-size: 14px; background: #f9f9f9; padding: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; background: #fff; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #d32f2f; color: white; }
    </style>
</head>
<body>
    <h1>OWASP ZAP Security Report</h1>
    <div class="summary">
        <p><strong>Target:</strong> <xsl:value-of select="//site/@name"/></p>
        <p><strong>Generated:</strong> <xsl:value-of select="//generated"/></p>
    </div>
    
    <h2>Security Alerts</h2>
    <xsl:for-each select="//alertitem">
        <xsl:variable name="riskcode" select="riskcode"/>
        <xsl:variable name="alertclass">
            <xsl:choose>
                <xsl:when test="$riskcode = '3'">high</xsl:when>
                <xsl:when test="$riskcode = '2'">medium</xsl:when>
                <xsl:when test="$riskcode = '1'">low</xsl:when>
                <xsl:otherwise>informational</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <div class="alert {$alertclass}">
            <div class="alert-name"><xsl:value-of select="name"/></div>
            <p><strong>Risk:</strong> <xsl:value-of select="riskdesc"/></p>
            <p><strong>Confidence:</strong> <xsl:value-of select="confidence"/></p>
            <div class="desc">
                <strong>Description:</strong><br/>
                <xsl:value-of select="desc"/>
            </div>
            <div class="desc">
                <strong>Solution:</strong><br/>
                <xsl:value-of select="solution"/>
            </div>
            <xsl:if test="uri">
                <div class="desc"><strong>Affected URLs:</strong></div>
                <xsl:for-each select="instances/instance">
                    <div class="url"><xsl:value-of select="uri"/></div>
                </xsl:for-each>
            </xsl:if>
        </div>
    </xsl:for-each>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
XSLT_EOF

                            # Convert XML to HTML using xsltproc
                            echo "Converting XML to HTML..."
                            docker run --rm \
                                -v "$PWD/zap-reports:/reports" \
                                alpine:latest \
                                sh -c "
                                    apk add --no-cache libxslt &&
                                    cd /reports &&
                                    xsltproc -o zap-report.html transform.xsl zap-report.xml &&
                                    echo 'HTML conversion complete' &&
                                    ls -lh zap-report.html
                                "
                            
                            echo "Verifying HTML report..."
                            if [ -f "$PWD/zap-reports/zap-report.html" ]; then
                                echo "SUCCESS: HTML report created"
                                ls -lh "$PWD/zap-reports/zap-report.html"
                            else
                                echo "ERROR: HTML report not created"
                            fi
                        else
                            echo "ERROR: XML report not found"
                        fi
                    '''
                }
                echo 'Running OWASP ZAP baseline scan...'
                sh '''
                    echo "docker ps -a";
                    docker run --rm \
                        --network devops \
                        -v "$PWD/zap-reports:/zap/wrk" \
                        ghcr.io/zaproxy/zaproxy:stable \
                        zap-baseline.py \
                            -t http://petclinic-app:8000 \
                            -r zap-report.html \
                            -m 0 || true
                '''
            }
            post {
                always {
                    script {
                        // Publish HTML report if it exists
                        if (fileExists('zap-reports/zap-report.html')) {
                            publishHTML(target: [
                                allowMissing: false,
                                keepAll: true,
                                reportDir: 'zap-reports',
                                reportFiles: 'zap-report.html',
                                reportName: 'OWASP ZAP Report'
                            ])
                        }
                        // Archive all artifacts
                        archiveArtifacts artifacts: 'zap-reports/*', allowEmptyArchive: true, fingerprint: true
                    }
                }
            }
        }



        stage('Copy Files with Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'simple-deploy.yaml',
                    inventory: 'inventory.ini',
                    disableHostKeyChecking: true,
                    colorized: true
                )
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
