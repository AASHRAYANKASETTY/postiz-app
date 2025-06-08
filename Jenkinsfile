pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.azure.com/scalesetpriority
                operator: In
                values:
                  - spot
  tolerations:
    - key: kubernetes.azure.com/scalesetpriority
      operator: Equal
      value: spot
      effect: NoSchedule
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
        gitParameter(
          name: 'BRANCH',
          type: 'PT_BRANCH',
          defaultValue: 'main',
          description: 'Git branch to build',
          branchFilter: '.*',
          selectedValue: 'DEFAULT',
          sortMode: 'ASCENDING',
          useRepository: 'https://github.com/AASHRAYANKASETTY/postiz-app.git'
        )
    }

    environment {
        NODE_VERSION = '20.17.0'
    }

    stages {
        stage('Set Metadata') {
            steps {
                script {
                    def ts = sh(script: 'date +%Y%m%d-%H%M', returnStdout: true).trim()
                    def cleanBranch = params.BRANCH.replaceAll('/', '-')
                    env.CLEAN_BRANCH = cleanBranch
                    env.BUILD_TIMESTAMP = ts
                    env.BUILD_REF = "${cleanBranch}-${env.BUILD_ID}-${ts}"
                    env.IMAGE_TAG = "xtremeverveacr.azurecr.io/postiz:${env.BUILD_REF}"
                }
            }
        }

        stage('Checkout Repository') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "${params.BRANCH}"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/AASHRAYANKASETTY/postiz-app.git',
                        credentialsId: 'gh-pat',
                        refspec: '+refs/heads/*:refs/remotes/origin/*'
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
                sh '''
                    NODE_OPTIONS="--max-old-space-size=4096" pnpm -r --workspace-concurrency=1 \
                    --filter ./apps/frontend \
                    --filter ./apps/backend \
                    --filter ./apps/workers \
                    --filter ./apps/cron run build
                '''
            }
        }

        stage('Build and Push Docker Image') {
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
            echo "✅ Build completed: ${env.IMAGE_TAG}"
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
