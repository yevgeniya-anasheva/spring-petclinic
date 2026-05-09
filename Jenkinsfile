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
        
        stage('Deploy to AWS EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        # Copy files to EC2
                        scp -o StrictHostKeyChecking=no docker-compose.yml ubuntu@3.93.60.251:/home/ubuntu/app/
                        scp -o StrictHostKeyChecking=no prometheus.yml ubuntu@3.93.60.251:/home/ubuntu/app/
                        
                        # Run Ansible playbook
                        ansible-playbook -i 3.93.60.251, \
                          --private-key $SSH_AUTH_SOCK \
                          -u ubuntu \
                          deploy.yml
                    '''
                }
            }
        }
    }
}
