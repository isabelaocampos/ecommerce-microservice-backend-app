pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Obteniendo código fuente...'
                git branch: 'master', url: 'https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Construyendo proyecto...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                sh 'mvn test'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completado'
        }
    }
}
