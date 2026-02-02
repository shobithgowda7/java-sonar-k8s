pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        SONARQUBE_ENV = 'sonarqube-k8s'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/shobithgowda7/java-sonar-k8s.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh '''
                    mvn clean verify sonar:sonar \
                      -Dsonar.projectKey=java-sonar-demo
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ Build, SonarQube analysis, and artifact generation successful!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs or SonarQube quality gate.'
        }
    }
}

