# Configuración Básica - Jenkins, Docker y Kubernetes

## 📋 Resumen
Este documento describe la configuración básica de Jenkins, Docker y Kubernetes para el proyecto ecommerce-microservice-backend-app.

## 🔧 Jenkins

### Jenkinsfile
```groovy
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
```

### Características
- Pipeline básico con 3 etapas: Checkout, Build, Test
- Uso de Maven para construcción
- Ejecución de pruebas unitarias
- Configuración simple y fácil de entender

## 🐳 Docker

### Dockerfile
```dockerfile
# Dockerfile básico para el proyecto ecommerce
FROM openjdk:11-jre-slim

# Crear directorio de trabajo
WORKDIR /app

# Copiar el JAR del proyecto
COPY target/*.jar app.jar

# Exponer puerto
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  # Base de datos
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: ecommerce
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  # Aplicación principal
  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/ecommerce
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=root

volumes:
  mysql_data:
```

### Características
- Imagen base Java 11
- Configuración de base de datos MySQL
- Variables de entorno para conexión
- Volúmenes persistentes

## ☸️ Kubernetes

### Namespace (k8s/namespace.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    name: ecommerce
```

### Deployment y Service (k8s/deployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-app
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ecommerce-app
  template:
    metadata:
      labels:
        app: ecommerce-app
    spec:
      containers:
      - name: ecommerce-app
        image: ecommerce-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
  namespace: ecommerce
spec:
  selector:
    app: ecommerce-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

### ConfigMap (k8s/configmap.yaml)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce
data:
  application.yml: |
    server:
      port: 8080
    spring:
      application:
        name: ecommerce-app
      profiles:
        active: prod
```

### Características
- Namespace dedicado para la aplicación
- Deployment con 2 réplicas
- Service tipo LoadBalancer
- ConfigMap para configuración
- Variables de entorno

## 🚀 Comandos de Despliegue

### Docker
```bash
# Construir imagen
docker build -t ecommerce-app .

# Ejecutar con docker-compose
docker-compose up -d

# Ver logs
docker-compose logs -f
```

### Kubernetes
```bash
# Crear namespace
kubectl apply -f k8s/namespace.yaml

# Desplegar aplicación
kubectl apply -f k8s/deployment.yaml

# Aplicar configuración
kubectl apply -f k8s/configmap.yaml

# Ver estado
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
```

## 📝 Notas Importantes

1. **Jenkins**: Configuración básica para CI/CD
2. **Docker**: Imagen simple con Java 11 y MySQL
3. **Kubernetes**: Despliegue básico con 2 réplicas
4. **Seguridad**: Configuraciones básicas sin autenticación avanzada
5. **Monitoreo**: Sin herramientas de monitoreo avanzadas

## 🔄 Próximos Pasos

1. Configurar credenciales en Jenkins
2. Implementar pruebas de integración
3. Agregar monitoreo y logging
4. Configurar autenticación y autorización
5. Implementar estrategias de despliegue avanzadas

---
*Documentación generada para el proyecto ecommerce-microservice-backend-app*
