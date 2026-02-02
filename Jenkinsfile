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
                      -Dsonar.projectKey=java-sonar-demo \
                      -Dsonar.projectName="Java Sonar K8s Demo"
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn package -DskipTests'
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
            echo '❌ Pipeline failed. Check SonarQube Quality Gate or build logs.'
        }
    }
}

