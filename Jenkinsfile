// ============================================
// Chattingo - Jenkins CI/CD Pipeline
// ============================================
// This Jenkinsfile automates the build, test, and deployment process
// for the Chattingo application across development and production environments

pipeline {
    agent any

    // ============================================
    // Environment Variables
    // ============================================
    environment {
        // Project Information
        PROJECT_NAME = 'chattingo'
        DOCKER_REGISTRY = 'docker.io'  // Change to your registry (e.g., your Docker Hub username)
        
        // Docker Images
        BACKEND_IMAGE = "${DOCKER_REGISTRY}/${PROJECT_NAME}-backend:${BUILD_NUMBER}"
        FRONTEND_IMAGE = "${DOCKER_REGISTRY}/${PROJECT_NAME}-frontend:${BUILD_NUMBER}"
        
        // Deployment Information
        VPS_HOST = credentials('vps-host')
        VPS_USER = credentials('vps-user')
        VPS_SSH_KEY = credentials('vps-ssh-key')
        
        // Docker Hub Credentials
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        
        // Paths
        BACKEND_PATH = './backend'
        FRONTEND_PATH = './frontend'
        APP_PORT = '8080'
        FRONTEND_PORT = '80'
        
        // Build options
        BUILD_OPTS = '-DskipTests=true'
    }

    // ============================================
    // Pipeline Options
    // ============================================
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        ansiColor('xterm')
    }

    // ============================================
    // Pipeline Triggers
    // ============================================
    triggers {
        // Trigger on GitHub push (requires GitHub plugin)
        githubPush()
        
        // Poll SCM every 15 minutes
        pollSCM('H/15 * * * *')
    }

    // ============================================
    // Build Stages
    // ============================================
    stages {
        // Stage 1: Checkout
        stage('Checkout') {
            steps {
                script {
                    echo '===== Starting Chattingo CI/CD Pipeline ====='
                    echo "Build Number: ${BUILD_NUMBER}"
                    echo "Job Name: ${JOB_NAME}"
                }
                
                checkout scm
                
                script {
                    // Get commit information
                    GIT_COMMIT = sh(returnStdout: true, script: 'git rev-parse HEAD').trim().take(7)
                    GIT_BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
                    echo "Commit: ${GIT_COMMIT}"
                    echo "Branch: ${GIT_BRANCH}"
                }
            }
        }

        // Stage 2: Code Quality Checks
        stage('Code Quality') {
            parallel {
                stage('Backend Analysis') {
                    steps {
                        script {
                            echo '===== Backend Code Quality Checks ====='
                            dir("${BACKEND_PATH}") {
                                // Run Maven tests
                                sh './mvnw clean test'
                                
                                // Optional: SonarQube analysis
                                // sh './mvnw sonar:sonar -Dsonar.projectKey=${PROJECT_NAME}-backend'
                            }
                        }
                    }
                }
                
                stage('Frontend Analysis') {
                    steps {
                        script {
                            echo '===== Frontend Code Quality Checks ====='
                            dir("${FRONTEND_PATH}") {
                                // Install dependencies
                                sh 'npm ci'
                                
                                // Run linting (if configured)
                                // sh 'npm run lint'
                                
                                // Run tests
                                sh 'npm test -- --watchAll=false'
                            }
                        }
                    }
                }
            }
        }

        // Stage 3: Build Docker Images
        stage('Build Docker Images') {
            steps {
                script {
                    echo '===== Building Docker Images ====='
                    
                    // Build backend image
                    echo "Building backend image: ${BACKEND_IMAGE}"
                    sh """
                        docker build -t ${BACKEND_IMAGE} \
                            -f ${BACKEND_PATH}/Dockerfile \
                            ${BACKEND_PATH}
                    """
                    
                    // Build frontend image
                    echo "Building frontend image: ${FRONTEND_IMAGE}"
                    sh """
                        docker build -t ${FRONTEND_IMAGE} \
                            -f ${FRONTEND_PATH}/Dockerfile \
                            ${FRONTEND_PATH}
                    """
                }
            }
        }

        // Stage 4: Security Scanning
        stage('Security Scan') {
            steps {
                script {
                    echo '===== Running Security Scans ====='
                    
                    // Optional: Trivy vulnerability scanning
                    // sh 'trivy image --severity HIGH,CRITICAL ${BACKEND_IMAGE}'
                    // sh 'trivy image --severity HIGH,CRITICAL ${FRONTEND_IMAGE}'
                    
                    echo 'Security scan would run here (Trivy, etc.)'
                }
            }
        }

        // Stage 5: Push to Registry
        stage('Push to Registry') {
            when {
                branch 'main'  // Only push on main branch
            }
            steps {
                script {
                    echo '===== Pushing Images to Registry ====='
                    
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${BACKEND_IMAGE}"
                        sh "docker push ${FRONTEND_IMAGE}"
                        sh 'docker logout'
                    }
                }
            }
        }

        // Stage 6: Deploy to VPS
        stage('Deploy to VPS') {
            when {
                branch 'main'  // Only deploy from main branch
            }
            steps {
                script {
                    echo '===== Deploying to VPS ====='
                    
                    // Create deployment script
                    sh '''
                        cat > /tmp/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "===== Starting Deployment ====="

# Stop running containers
docker-compose -f /opt/chattingo/docker-compose.yml down || true

# Pull latest images
docker pull ${BACKEND_IMAGE}
docker pull ${FRONTEND_IMAGE}

# Update docker-compose file
cd /opt/chattingo

# Start services
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Run health checks
docker-compose ps
docker exec chattingo-backend curl -f http://localhost:8080/health || exit 1

echo "===== Deployment Complete ====="
EOF
                        chmod +x /tmp/deploy.sh
                    '''
                    
                    // Execute deployment on VPS (requires SSH key)
                    // This is a placeholder - adjust based on your VPS setup
                    echo 'Deployment script prepared'
                    // sh 'scp -i ${VPS_SSH_KEY} /tmp/deploy.sh ${VPS_USER}@${VPS_HOST}:/tmp/'
                    // sh 'ssh -i ${VPS_SSH_KEY} ${VPS_USER}@${VPS_HOST} /tmp/deploy.sh'
                }
            }
        }

        // Stage 7: Smoke Testing
        stage('Smoke Tests') {
            steps {
                script {
                    echo '===== Running Smoke Tests ====='
                    
                    // Start docker-compose stack
                    sh 'docker-compose up -d'
                    
                    // Wait for services
                    sh 'sleep 20'
                    
                    // Test backend
                    sh '''
                        echo "Testing backend..."
                        curl -f http://localhost:8080/auth || exit 1
                        echo "Backend is responding"
                    '''
                    
                    // Test frontend
                    sh '''
                        echo "Testing frontend..."
                        curl -f http://localhost/ || exit 1
                        echo "Frontend is responding"
                    '''
                }
            }
        }
    }

    // ============================================
    // Post Actions
    // ============================================
    post {
        success {
            echo "✅ Pipeline succeeded!"
            // Optional: Send success notification
            // emailext(
            //     subject: "Pipeline Success: ${JOB_NAME} #${BUILD_NUMBER}",
            //     body: "Build succeeded. Commit: ${GIT_COMMIT}",
            //     to: 'team@example.com'
            // )
        }
        
        failure {
            echo "❌ Pipeline failed!"
            // Optional: Send failure notification
            // emailext(
            //     subject: "Pipeline Failed: ${JOB_NAME} #${BUILD_NUMBER}",
            //     body: "Build failed. Check logs for details.",
            //     to: 'team@example.com'
            // )
        }
        
        always {
            // Clean up
            sh 'docker-compose down || true'
            
            // Archive logs
            archiveArtifacts(
                artifacts: '**/logs/**/*.log',
                allowEmptyArchive: true
            )
        }
    }
}
