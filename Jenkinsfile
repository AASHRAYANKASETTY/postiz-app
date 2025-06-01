pipeline {
  agent any

  tools {
    nodejs 'nodejs' // Name from Global Tool Configuration
  }

  environment {
    PR_NUMBER = "${env.CHANGE_ID}"
    IMAGE_TAG = "ghcr.io/gitroomhq/postiz-app-pr:${env.CHANGE_ID}"
    PYTHON = "/usr/bin/python3" // Added to satisfy node-gyp
  }

  stages {
    stage('Checkout Repository') {
      steps {
        checkout scm
      }
    }

    stage('Check Node.js and npm') {
      steps {
        sh 'node -v'
        sh 'npm -v'
      }
    }

    stage('Install Dependencies') {
      steps {
          sh '''
            apt-get update
            apt-get install -y python3 make g++
            npm ci --legacy-peer-deps
          '''
        }
    }

    stage('Build Project') {
      steps {
        sh 'npm run build'
      }
    }

    stage('Build and Push Docker Image') {
      when {
        expression { return env.CHANGE_ID != null }
      }
      steps {
        withCredentials([string(credentialsId: 'gh-pat', variable: 'GITHUB_PASS')]) {
          sh '''
            echo "$GITHUB_PASS" | docker login ghcr.io -u "egelhaus" --password-stdin
            docker build -f Dockerfile.dev -t $IMAGE_TAG .
            docker push $IMAGE_TAG
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
      echo '❌ Build or push failed.'
    }
  }
}
