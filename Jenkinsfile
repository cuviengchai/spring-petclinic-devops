pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out Spring PetClinic source code...'
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
