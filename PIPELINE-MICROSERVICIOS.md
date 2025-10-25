# Pipeline de Construcción de Microservicios

## Objetivo
Crear pipelines en Jenkins para construir los 6 microservicios del proyecto en ambiente de desarrollo (dev).

## Microservicios y sus Dependencias

### Fase 1 - Servicios Base (sin dependencias)
1. **user-service** (Puerto 8700)
2. **product-service** (Puerto 8500)

### Fase 2 - Servicios que dependen de Fase 1
3. **favourite-service** (Puerto 8800) - Depende de user + product
4. **order-service** (Puerto 8300) - Depende de user + product

### Fase 3 - Servicios que dependen de Fase 2
5. **payment-service** (Puerto 8400) - Depende de order
6. **shipping-service** (Puerto 8600) - Depende de order

### Servicios de Infraestructura (no se construyen en este pipeline)
- zipkin
- service-discovery
- cloud-config

---

## Pasos de Implementación

### 1. Instalar Maven en Jenkins

Ya instalé Maven 3.8.1 en el contenedor de Jenkins con este comando:
```powershell
docker exec -u root jenkins bash -c "cd /opt && curl -O https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz && tar -xzf apache-maven-3.8.1-bin.tar.gz && rm apache-maven-3.8.1-bin.tar.gz && ln -s /opt/apache-maven-3.8.1/bin/mvn /usr/local/bin/mvn"
```

Verifiqué la instalación:
```powershell
docker exec jenkins mvn -version
```

### 2. Configurar Maven en Jenkins

1. Accedí a Jenkins: http://localhost:8081
2. Fui a **Manage Jenkins** > **Global Tool Configuration**
3. En la sección **Maven**:
   - Hice clic en **"Add Maven"**
   - **Name:** `Maven-3.8.1`
   - Desmarqué **"Install automatically"**
   - **MAVEN_HOME:** `/opt/apache-maven-3.8.1`
4. Guardé la configuración

### 3. Crear el Pipeline de Microservicios

Creé un nuevo pipeline en Jenkins:

**Configuración del Pipeline:**
- **Nombre:** `build-microservices-dev`
- **Tipo:** Pipeline
- **Pipeline Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** https://github.com/isabelaocampos/ecommerce-microservice-backend-app.git
- **Branch:** */master
- **Script Path:** Jenkinsfile

### 4. Estructura del Pipeline

El Jenkinsfile que creé tiene estos stages:

```
1. Checkout - Clona el repositorio
2. Build Microservices - Fase 1 (Paralelo)
   ├─ Build user-service
   └─ Build product-service
3. Build Microservices - Fase 2 (Paralelo)
   ├─ Build favourite-service
   └─ Build order-service
4. Build Microservices - Fase 3 (Secuencial)
   ├─ Build payment-service
   └─ Build shipping-service
5. Verificar Artefactos - Lista los JAR generados
6. Tests Unitarios (Paralelo) - Ejecuta tests de todos los servicios
```

**Características importantes:**
- Construye en fases respetando las dependencias
- Los servicios sin dependencias se construyen en paralelo (más rápido)
- Usa `mvn clean package -DskipTests` para el build
- Ejecuta tests en paralelo al final con `mvn test`
- Muestra el tamaño de los JAR generados

### 5. Ejecutar el Pipeline

1. Fui al pipeline `build-microservices-dev`
2. Hice clic en **"Build Now"**
3. El pipeline ejecutó todos los stages
4. Revisé el **Console Output** para ver el progreso
5. La **Stage View** mostró todos los stages en verde

### 6. Resultado

El pipeline construyó exitosamente todos los microservicios:

```
✅ user-service (8700)
✅ product-service (8500)
✅ favourite-service (8800)
✅ order-service (8300)
✅ payment-service (8400)
✅ shipping-service (8600)
```

Cada uno generó su archivo JAR en la carpeta `target/`:
- `user-service/target/user-service-0.1.0.jar`
- `product-service/target/product-service-0.1.0.jar`
- `favourite-service/target/favourite-service-0.1.0.jar`
- `order-service/target/order-service-0.1.0.jar`
- `payment-service/target/payment-service-0.1.0.jar`
- `shipping-service/target/shipping-service-0.1.0.jar`

---

## Ventajas de este Enfoque

1. **Respeta dependencias:** Los servicios se construyen en el orden correcto
2. **Build paralelo:** Los servicios independientes se construyen simultáneamente
3. **Validación automática:** Tests unitarios se ejecutan automáticamente
4. **Trazabilidad:** Cada build queda registrado en Jenkins
5. **Reutilizable:** El mismo pipeline sirve para dev, qa y prod

---

## Comandos Útiles

Ver si el build generó los JAR:
```powershell
docker exec jenkins ls -lh /var/jenkins_home/workspace/build-microservices-dev/*/target/*.jar
```

Ver logs de un build específico:
```powershell
# En Jenkins: Pipeline > Build #X > Console Output
```

Limpiar workspace:
```powershell
# En Jenkins: Pipeline > Workspace > Wipe Out Workspace
```

---

**Isabella Ocampo - 25 de Octubre de 2025**
