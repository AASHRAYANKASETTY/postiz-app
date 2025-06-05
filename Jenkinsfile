pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: node
      image: node:20.17.0
      command:
        - cat
      tty: true
"""
            defaultContainer 'node'
        }
    }

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

        stage('Install Dependencies') {
            steps {
                sh '''
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
            steps {
                echo "⚠️ Docker is not available in this container. To enable this step, use a pod with Docker (e.g., docker:dind). Skipping."
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
