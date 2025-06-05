pipeline {
    agent any

    options {
        skipDefaultCheckout()
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    environment {
        NODE_VERSION = '20.17.0'
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

        stage('Check Node.js and npm') {
            steps {
                sh 'node -v || echo "❌ Node.js not found"'
                sh 'npm -v || echo "❌ npm not found"'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    set -e
                    npm install -g pnpm
                    pnpm install --frozen-lockfile
                '''
            }
        }

        stage('Build Project') {
            steps {
                sh 'pnpm run build'
            }
        }

        stage('Build and Push Docker Image') {
            when {
                expression { return env.PR_NUMBER != null }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker build -f Dockerfile.dev -t $IMAGE_TAG .
                        docker push $IMAGE_TAG
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and push completed successfully!'
        }
        failure {
            echo '❌ Build failed. Please check logs.'
        }
    }
}
