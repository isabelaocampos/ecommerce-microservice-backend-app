# Guía: Configurar y Ejecutar Pipeline STAGE en Jenkins

## Estado Actual

✅ **Jenkins está completamente configurado y listo** para ejecutar el pipeline de despliegue a Kubernetes (STAGE environment)

### Verificación Realizada

Todos los pre-requisitos están instalados y funcionando:
- ✅ Docker CLI disponible en Jenkins
- ✅ kubectl configurado para acceder a Minikube
- ✅ minikube disponible
- ✅ Kubernetes cluster funcionando (Minikube)
- ✅ Namespace `ecommerce` creado
- ✅ Maven 3.8.1 configurado en Jenkins
- ✅ JDK 21 disponible
- ✅ 6 deployments YAML listos en `k8s/`
- ✅ `Jenkinsfile-stage` completado

## Configuración del Pipeline en Jenkins

### Paso 1: Abrir Jenkins

Abre tu navegador y ve a: **http://localhost:8081**

### Paso 2: Crear el Pipeline

1. Haz clic en **"New Item"** o **"Nueva tarea"**
2. Ingresa el nombre: `deploy-microservices-stage`
3. Selecciona **"Pipeline"**
4. Haz clic en **"OK"**

### Paso 3: Configurar el Pipeline

En la página de configuración:

#### Sección "General"
- (Opcional) Descripción: `Pipeline para desplegar microservicios en Kubernetes STAGE environment`

#### Sección "Pipeline"

1. **Definition**: Selecciona `Pipeline script from SCM`

2. **SCM**: Selecciona `Git` (o `None` si usas script directo)

   **Opción A - Si tienes Git configurado:**
   - **Repository URL**: Ingresa la URL de tu repositorio
   - **Credentials**: Si es privado, configura las credenciales
   - **Branch**: `*/main` o la rama que uses

   **Opción B - Si NO tienes Git (script directo):**
   - **Definition**: Selecciona `Pipeline script`
   - Copia y pega el contenido completo del archivo `Jenkinsfile-stage`

3. **Script Path** (solo si usaste opción A): `Jenkinsfile-stage`

4. Haz clic en **"Save"** o **"Guardar"**

## Ejecución del Pipeline

### Iniciar el Build

1. En la página del pipeline `deploy-microservices-stage`
2. Haz clic en **"Build Now"** o **"Construir ahora"**
3. Observa el progreso en la sección **"Build History"**

### Monitorear la Ejecución

1. Haz clic en el número del build (ejemplo: `#1`)
2. Haz clic en **"Console Output"** para ver los logs en tiempo real

### Etapas del Pipeline

El pipeline ejecutará las siguientes **9 etapas** en orden:

1. **Checkout** - Obtiene el código fuente
2. **Build Phase 1** (paralelo) - Compila user-service y product-service
3. **Build Phase 2** (paralelo) - Compila favourite-service y order-service
4. **Build Phase 3** (paralelo) - Compila payment-service y shipping-service
5. **Verify Artifacts** - Verifica que todos los JARs se generaron
6. **Unit Tests** - Ejecuta pruebas unitarias de todos los servicios
7. **Build Docker Images** - Construye 6 imágenes Docker
8. **Deploy to Kubernetes** - Despliega en namespace `ecommerce`
9. **Integration Tests** - Verifica health checks de todos los servicios

### Tiempos Estimados

- **Build total**: 8-12 minutos (dependiendo de tu máquina)
- Build de servicios: 2-3 min
- Unit tests: 1-2 min
- Docker images: 3-5 min
- Deploy K8s: 1-2 min
- Integration tests: 1 min

## Verificación Post-Despliegue

### Verificar Pods en Kubernetes

Desde PowerShell:

```powershell
kubectl get pods -n ecommerce
```

Deberías ver **12 pods** (6 servicios × 2 réplicas cada uno) con estado `Running`:

```
NAME                                READY   STATUS    RESTARTS   AGE
user-service-xxxxxxxxx-xxxxx        1/1     Running   0          2m
user-service-xxxxxxxxx-xxxxx        1/1     Running   0          2m
product-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
product-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
favourite-service-xxxxxxxxx-xxxxx   1/1     Running   0          2m
favourite-service-xxxxxxxxx-xxxxx   1/1     Running   0          2m
order-service-xxxxxxxxx-xxxxx       1/1     Running   0          2m
order-service-xxxxxxxxx-xxxxx       1/1     Running   0          2m
payment-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
payment-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
shipping-service-xxxxxxxxx-xxxxx    1/1     Running   0          2m
shipping-service-xxxxxxxxx-xxxxx    1/1     Running   0          2m
```

### Verificar Servicios

```powershell
kubectl get services -n ecommerce
```

Deberías ver **6 servicios** tipo NodePort:

```
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
user-service        NodePort   10.x.x.x        <none>        8700:30700/TCP   2m
product-service     NodePort   10.x.x.x        <none>        8500:30500/TCP   2m
favourite-service   NodePort   10.x.x.x        <none>        8800:30800/TCP   2m
order-service       NodePort   10.x.x.x        <none>        8300:30300/TCP   2m
payment-service     NodePort   10.x.x.x        <none>        8400:30400/TCP   2m
shipping-service    NodePort   10.x.x.x        <none>        8600:30600/TCP   2m
```

### Probar los Endpoints

Obtén la IP de Minikube:

```powershell
minikube ip
```

Ejemplo de salida: `192.168.49.2`

Luego prueba los health checks (reemplaza con tu IP):

```powershell
# User Service
curl http://192.168.49.2:30700/actuator/health

# Product Service
curl http://192.168.49.2:30500/actuator/health

# Favourite Service
curl http://192.168.49.2:30800/actuator/health

# Order Service
curl http://192.168.49.2:30300/actuator/health

# Payment Service
curl http://192.168.49.2:30400/actuator/health

# Shipping Service
curl http://192.168.49.2:30600/actuator/health
```

Todos deberían devolver: `{"status":"UP"}`

## Solución de Problemas

### Si el build falla

1. **Revisa los logs** en Console Output
2. **Verifica** que todas las herramientas están disponibles:
   ```powershell
   .\verify-jenkins-ready.ps1
   ```

### Si los pods no inician

1. **Verifica el estado de los pods**:
   ```powershell
   kubectl describe pod <pod-name> -n ecommerce
   ```

2. **Revisa los logs del pod**:
   ```powershell
   kubectl logs <pod-name> -n ecommerce
   ```

3. **Verifica eventos del namespace**:
   ```powershell
   kubectl get events -n ecommerce --sort-by='.lastTimestamp'
   ```

### Si las imágenes Docker no se encuentran

El Jenkinsfile usa `imagePullPolicy: Never` porque las imágenes se construyen localmente.

Verifica que las imágenes existen:

```powershell
docker images | Select-String "ecommerce"
```

Deberías ver 6 imágenes:
- `ecommerce/user-service:latest`
- `ecommerce/product-service:latest`
- `ecommerce/favourite-service:latest`
- `ecommerce/order-service:latest`
- `ecommerce/payment-service:latest`
- `ecommerce/shipping-service:latest`

### Recrear el despliegue

Si necesitas empezar de nuevo:

```powershell
# Eliminar todos los recursos en el namespace
kubectl delete all --all -n ecommerce

# Volver a ejecutar el pipeline en Jenkins
```

## Recursos Creados

### Archivos de Infraestructura

- `Jenkinsfile-stage` - Pipeline CI/CD para STAGE environment
- `k8s/user-service-deployment.yaml` - Deployment + Service para User
- `k8s/product-service-deployment.yaml` - Deployment + Service para Product
- `k8s/favourite-service-deployment.yaml` - Deployment + Service para Favourite
- `k8s/order-service-deployment.yaml` - Deployment + Service para Order
- `k8s/payment-service-deployment.yaml` - Deployment + Service para Payment
- `k8s/shipping-service-deployment.yaml` - Deployment + Service para Shipping

### Documentación

- `GUIA-PIPELINE-STAGE-JENKINS.md` - Esta guía
- `PIPELINE-BUILD-DEV.md` - Documentación del pipeline DEV
- `PIPELINE-MICROSERVICIOS.md` - Documentación general de pipelines

### Scripts de Automatización

- `deploy-microservices-k8s.ps1` - Script PowerShell para deploy manual
- `test-microservices-k8s.ps1` - Script para testing de integración
- `verify-jenkins-ready.ps1` - Script de verificación de pre-requisitos

## Próximos Pasos

Una vez que el pipeline de STAGE esté funcionando correctamente:

1. **Monitorear** las métricas de los servicios
2. **Configurar** pruebas E2E adicionales
3. **Implementar** un pipeline de PRODUCCIÓN
4. **Configurar** estrategias de rollout (Blue/Green, Canary)
5. **Implementar** monitoreo con Prometheus/Grafana
6. **Configurar** alertas automáticas

## Notas Importantes

- **Namespace**: Todos los servicios se despliegan en el namespace `ecommerce`
- **Réplicas**: Cada servicio tiene 2 réplicas para alta disponibilidad
- **Health Checks**: Todos los servicios tienen liveness y readiness probes
- **Recursos**: Los pods tienen límites de CPU (200m) y memoria (512Mi)
- **Puertos**: Se usan NodePorts para acceso externo (307xx)
- **Network**: Jenkins está en la red `minikube` para acceso directo

## Contacto y Soporte

Si encuentras problemas:
1. Revisa los logs del pipeline en Jenkins
2. Ejecuta `.\verify-jenkins-ready.ps1` para diagnóstico
3. Verifica los eventos de Kubernetes
4. Consulta la documentación en los archivos MD del proyecto
