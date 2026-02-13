pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        SONARQUBE_ENV = 'sonarqube-k8s'
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '831103387233'
        ECR_REPO = 'java-sonar-demo'
        IMAGE_TAG = '1.0'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
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

        stage('Build & Deploy to Nexus') {
            steps {
                sh 'mvn deploy -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                  docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Docker Tag') {
            steps {
                sh '''
                  docker tag ${ECR_REPO}:${IMAGE_TAG} \
                  ${ECR_URI}/${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Docker Push to ECR') {
            steps {
                sh '''
                  aws ecr get-login-password --region ${AWS_REGION} \
                  | docker login --username AWS --password-stdin ${ECR_URI}

                  docker push ${ECR_URI}/${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI + SonarQube + Nexus + Docker + ECR pipeline SUCCESSFUL!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}

