pipeline {

    agent any

    environment {
        MAVEN_HOME = tool 'maven'
        SONAR_HOME = tool 'sonar'
        NODE_HOME = tool 'npm'
        PATH = "${NODE_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: "https://github.com/dhruvmoradiya69/Deployment-shopping-cart-spring-boot.git", branch: "main"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh "${MAVEN_HOME}/bin/mvn clean package -DskipTests=true"
            }
        }

        stage('Sonarqube Quality Analysis') {
            steps {
                withSonarQubeEnv("sonarqube") {
                    sh "$SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=shop-cart-app -Dsonar.projectKey=shop-cart-app -Dsonar.java.binaries=target/classes"
                }
            }
        }

        stage('Sonar Quality Gate') {
            steps {
                timeout(time: 2, unit: "MINUTES") {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'owasp'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy File Scan') {
            steps {
                sh 'trivy fs --format table -o trivy-fs-report.html .'
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t shopping-cart:latest ."
            }
        }
        
        stage('Scan Docker Image') {
            steps {
                sh 'trivy image --format table -o trivy-shop-report.html shopping-cart:latest'
            }
        }

        stage("Push Docker Images") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "dockerhubid",
                    usernameVariable: "dockerHubUser", 
                    passwordVariable: "dockerHubPass"
                )]) {
                    sh 'echo $dockerHubPass | docker login -u $dockerHubUser --password-stdin'
                    sh "docker image tag shopping-cart:latest ${env.dockerHubUser}/shopping-cart:latest"
                    sh "docker push ${env.dockerHubUser}/shopping-cart:latest"
                }
            }
        }
    }

     post {
    always {
        emailext attachLog: true,
            attachmentsPattern: '**/trivy-*-report.html, **/dependency-check-report.xml',
            mimeType: 'text/html',
            subject: "Build #${BUILD_NUMBER} - ${currentBuild.currentResult}",
            to: 'dhruvmoradiya69000@gmail.com',
            body: """<html>
  <head>
    <style>
      .header {
        background-color: #f44336;
        color: white;
        padding: 10px;
        text-align: center;
      }
      .content {
        padding: 20px;
        font-family: sans-serif;
      }
      .btn {
        display: inline-block;
        padding: 10px 15px;
        background-color: #4CAF50;
        color: white;
        text-decoration: none;
        border-radius: 5px;
      }
    </style>
  </head>
  <body>
    <div class="header">
      <h1>🔔 Build Notification</h1>
    </div>
    <div class="content">
      <p><strong>Project:</strong> ${env.JOB_NAME}</p>
      <p><strong>Status:</strong> ${currentBuild.currentResult}</p>
      <p><strong>Build Number:</strong> ${BUILD_NUMBER}</p>
      <p><strong>Branch:</strong> ${env.GIT_BRANCH}</p>
      <p><a class="btn" href="${env.BUILD_URL}">🔍 View Build Console</a></p>
    </div>
  </body>
</html>"""
        }
    }
}