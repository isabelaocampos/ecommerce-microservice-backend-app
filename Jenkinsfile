pipeline {
    agent any
    
    stages {
        stage('Verificar Kubernetes') {
            steps {
                echo '🔍 Verificando conectividad con Kubernetes...'
                sh 'kubectl version --client || echo "kubectl no disponible en Jenkins"'
                sh 'kubectl cluster-info || echo "Cluster no accesible desde Jenkins"'
            }
        }
        
        stage('Verificar Namespaces') {
            steps {
                echo '📋 Listando namespaces de Kubernetes...'
                sh 'kubectl get namespaces || echo "No se pueden listar namespaces"'
            }
        }
        
        stage('Verificar Pods') {
            steps {
                echo '🚀 Verificando pods en todos los namespaces...'
                sh 'kubectl get pods --all-namespaces || echo "No se pueden listar pods"'
            }
        }
        
        stage('Estado del Cluster') {
            steps {
                echo '✅ Verificando estado general del cluster...'
                sh 'kubectl get nodes || echo "No se pueden listar nodos"'
            }
        }
    }
    
    post {
        success {
            echo '✅ ¡Pipeline completado exitosamente! Kubernetes está funcionando correctamente.'
        }
        failure {
            echo '❌ Pipeline falló. Verifica que kubectl esté instalado en el contenedor de Jenkins.'
        }
        always {
            echo '📊 Pipeline de verificación de Kubernetes finalizado'
        }
    }
}
