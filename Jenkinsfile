pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    environment {
        PR_NUMBER = "${env.CHANGE_ID ?: 'manual'}"
        IMAGE_TAG = "aashrayankasetty/firewallcheck:${env.PR_NUMBER}"
    }

    stages {
        stage('Checkout Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AASHRAYANKASETTY/postiz-app.git',
                        credentialsId: 'gh-pat'
                    ]]
                ])
            }
        }

        stage('Build Inside Node Container') {
            steps {
                script {
                    docker.image('node:20.17.0').inside {
                        sh 'node -v'
                        sh 'npm -v'
                        sh 'npm install -g pnpm'
                        sh 'pnpm install --frozen-lockfile'
                        sh 'pnpm run build'
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    // Now we need a docker-capable agent (you may need to run this on an agent with Docker)
                    // OR: skip this if you are NOT using docker in Jenkins
                    sh '''
                        echo "⚠️ Docker CLI not available in Bitnami controller by default."
                        echo "You must run this stage on an agent with Docker, or set up a Kubernetes PodTemplate with docker:dind."
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build completed successfully!'
        }
        failure {
            echo '❌ Build failed. Please check logs.'
        }
    }
}
