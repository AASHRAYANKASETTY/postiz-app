pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  volumes:
    - name: docker-graph-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
  containers:
    - name: node
      image: node:20.17.0
      command: ['cat']
      tty: true
      resources:
        requests:
          memory: "2Gi"
          cpu: "1000m"
        limits:
          memory: "4Gi"
          cpu: "2000m"
      volumeMounts:
        - mountPath: "/home/jenkins/agent"
          name: workspace-volume
    - name: docker
      image: docker:dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ''
      resources:
        requests:
          memory: "512Mi"
          cpu: "500m"
        limits:
          memory: "1Gi"
          cpu: "1000m"
      volumeMounts:
        - mountPath: /var/lib/docker
          name: docker-graph-storage
        - mountPath: "/home/jenkins/agent"
          name: workspace-volume
  imagePullSecrets:
    - name: acr-secret
"""
            defaultContainer 'node'
        }
    }

    options {
        skipDefaultCheckout()
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    environment {
        NODE_VERSION = '20.17.0'
        PR_NUMBER = "${env.CHANGE_ID}"
        IMAGE_TAG = "xtremeverveacr.azurecr.io/firewallcheck:${env.CHANGE_ID}"
    }

    stages {
        stage('Checkout Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH}" ]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AASHRAYANKASETTY/postiz-app.git',
                        credentialsId: 'gh-pat'
                    ]]
                ])
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
                expression { return env.CHANGE_ID != null }
            }
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'acr-creds', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                        sh '''
                            echo "$ACR_PASS" | docker login xtremeverveacr.azurecr.io -u "$ACR_USER" --password-stdin
                            docker build -f Dockerfile.dev -t $IMAGE_TAG .
                            docker push $IMAGE_TAG
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Build completed successfully!'
            echo '✅ Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
            echo '❌ Build failed!'
        }
    }
}
