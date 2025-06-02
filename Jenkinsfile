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
          set -eux
          echo "🛠 Updating apt and installing build tools"
          sudo apt-get update -y
          sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 make g++

          echo "📦 Installing pnpm"
          npm install -g pnpm@10.6.1

          echo "📦 Installing node modules"
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
