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
      image: xtremeverveacr.azurecr.io/node-pnpm:20.17.0
      command: ['sh', '-c', 'cat']
      tty: true
      env:
        - name: NODE_OPTIONS
          value: "--max-old-space-size=4096"
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
      volumeMounts:
        - mountPath: /var/lib/docker
          name: docker-graph-storage
        - mountPath: "/home/jenkins/agent"
          name: workspace-volume
"""
            defaultContainer 'node'
        }
    }

    options {
        skipDefaultCheckout()
        timeout(time: 30, unit: 'MINUTES')
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
    }

    environment {
        NODE_VERSION = '20.17.0'
        IMAGE_NAME = 'postiz-app'
        ACR_REGISTRY = 'xtremeverveacr.azurecr.io'
        IMAGE_TAG = "${ACR_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
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

        stage('Install Dependencies') {
            steps {
                sh '''
                    pnpm install --frozen-lockfile
                '''
            }
        }

        stage('Build Project') {
            parallel {
                stage('Build Frontend') {
                    steps {
                        sh '''
                            pnpm --filter ./apps/frontend run build
                        '''
                    }
                }
                stage('Build Backend') {
                    steps {
                        sh '''
                            pnpm --filter ./apps/backend run build
                        '''
                    }
                }
                stage('Build Workers') {
                    steps {
                        sh '''
                            pnpm --filter ./apps/workers run build
                        '''
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'acr-creds', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                        sh '''
                            echo "$ACR_PASS" | docker login $ACR_REGISTRY -u "$ACR_USER" --password-stdin
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
            echo '✅ Build completed successfully!'
        }
        failure {
            echo '❌ Build failed!'
        }
        always {
            echo "Build Finished for Branch: ${params.BRANCH}"
        }
    }
}
