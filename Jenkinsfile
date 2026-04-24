pipeline {
    agent any

    tools {
        maven 'Maven 3.x'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Unit Test') {
            steps {
                sh 'mvn clean test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarCloud Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                sh 'mvn sonar:sonar \
                    -Dsonar.projectKey=yevgeniya-anasheva_spring-petclinic \
                    -Dsonar.organization=yevgeniya-anasheva \
                    -Dsonar.host.url=https://sonarcloud.io \
                    -Dsonar.login=${SONAR_TOKEN}'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def customImage = docker.build("yanasheva/petclinic:${env.BUILD_ID}")
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'ansible-playbook -i ./inventory deploy.yml'
            }
        }
    }
}
