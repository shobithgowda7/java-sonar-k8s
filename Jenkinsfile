pipeline {
    agent any

    tools {
        maven 'maven-3'
    }

    environment {
        SONARQUBE_ENV = 'sonarqube-k8s'
        AWS_REGION    = 'ap-south-1'
        ECR_REGISTRY  = '831103387233.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPO      = 'java-sonar-demo'

        NEXUS_URL     = 'http://13.126.176.194:32081'
        NEXUS_REPO    = 'maven-releases'
        GROUP_ID      = 'com/example'
        ARTIFACT_ID  = 'java-sonar-demo'
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

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Push Artifact to Nexus') {
            steps {
                sh 'mvn deploy -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def VERSION = sh(
                        script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout",
                        returnStdout: true
                    ).trim()

                    withCredentials([usernamePassword(
                        credentialsId: 'nexus-cred',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASSWORD'
                    )]) {
                        sh """
                        docker build \
                          --build-arg NEXUS_URL=${NEXUS_URL} \
                          --build-arg REPO=${NEXUS_REPO} \
                          --build-arg GROUP_ID=${GROUP_ID} \
                          --build-arg ARTIFACT_ID=${ARTIFACT_ID} \
                          --build-arg VERSION=${VERSION} \
                          --build-arg NEXUS_USER=${NEXUS_USER} \
                          --build-arg NEXUS_PASSWORD=${NEXUS_PASSWORD} \
                          -t ${ECR_REPO}:${VERSION} .
                        """
                    }
                }
            }
        }
        
        stage('Docker Tag & Push to ECR') {
            steps {
                script {
                    def VERSION = sh(
                        script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout",
                        returnStdout: true
                    ).trim()

                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} \
                      | docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker tag ${ECR_REPO}:${VERSION} ${ECR_REGISTRY}/${ECR_REPO}:${VERSION}
                    docker push ${ECR_REGISTRY}/${ECR_REPO}:${VERSION}
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Artifact build → Nexus publish → Docker → ECR completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}
