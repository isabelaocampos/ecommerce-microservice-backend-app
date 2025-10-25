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
