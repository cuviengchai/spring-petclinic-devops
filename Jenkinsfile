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

    stage('Build') {
      steps {
        echo 'Building Spring PetClinic application...'
        sh './gradlew clean build'
      }
    }
  }
}