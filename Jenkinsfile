pipeline {

    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git url: "https://github.com/dhruvmoradiya69/Deployment-shopping-cart-spring-boot.git", branch: "main"
            }
        }
        
        stage('Build Image') {
            steps {
                sh "docker build -t shopping-cart:latest ."
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
        
        stage('Deploy Application') {
            steps {
                sh "docker compose down && docker compose up -d --build"
            }
        }
        
        stage('Remove Unused Images'){
            steps{
               sh "docker image prune -a -f"
            }
        }
    }
}