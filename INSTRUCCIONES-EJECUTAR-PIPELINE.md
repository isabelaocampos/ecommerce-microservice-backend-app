# Instrucciones: Ejecutar Pipeline STAGE en Jenkins

## ¡Todo está listo! Sigue estos pasos exactos:

---

## PASO 1: Verificar que todo está OK

Abre PowerShell en la carpeta del proyecto y ejecuta:

```powershell
.\verify-jenkins-ready.ps1
```

**Resultado esperado**: Debe decir "OK - TODOS LOS CHECKS PASARON"

Si algún check falla, NO continúes. Reporta el error.

---

## PASO 2: Abrir Jenkins

1. Abre tu navegador web (Chrome, Edge, Firefox)
2. Ve a: **http://localhost:8081**
3. Inicia sesión con tus credenciales de Jenkins

---

## PASO 3: Crear el Pipeline

### 3.1 Click en "New Item"

En la página principal de Jenkins, haz click en **"New Item"** (o **"Nueva tarea"** si está en español)

### 3.2 Configurar el nombre

1. En el campo **"Enter an item name"**, escribe: `deploy-microservices-stage`
2. Selecciona **"Pipeline"** de la lista
3. Click en **"OK"**

### 3.3 Configurar el Pipeline Script

En la página de configuración del pipeline:

#### Opción A: Script desde el archivo (Recomendado)

1. Baja hasta la sección **"Pipeline"**
2. En **"Definition"**, selecciona: `Pipeline script from SCM`
3. En **"SCM"**, selecciona: `Git`
4. En **"Repository URL"**, ingresa la URL de tu repositorio
5. En **"Branch Specifier"**, deja: `*/main` (o tu rama principal)
6. En **"Script Path"**, escribe: `Jenkinsfile-stage`
7. Click en **"Save"**

#### Opción B: Script directo (Si no tienes Git configurado)

1. Baja hasta la sección **"Pipeline"**
2. En **"Definition"**, deja seleccionado: `Pipeline script`
3. En el campo de texto grande, copia y pega TODO el contenido del archivo `Jenkinsfile-stage`
4. Click en **"Save"**

---

## PASO 4: Ejecutar el Pipeline

### 4.1 Iniciar el Build

1. En la página del pipeline `deploy-microservices-stage`
2. Haz click en **"Build Now"** (o **"Construir ahora"**)
3. Verás que aparece un nuevo build en **"Build History"** (ejemplo: #1)

### 4.2 Monitorear el Progreso

1. Haz click en el número del build (ejemplo: **#1**)
2. Haz click en **"Console Output"** (o **"Salida de consola"**)
3. Verás los logs en tiempo real

**Alternativamente**, puedes ver el progreso visual:
- En la página del build, verás las **9 etapas** del pipeline
- Cada etapa mostrará su estado: ⏳ En progreso, ✅ Exitosa, ❌ Fallida

---

## PASO 5: Interpretar los Resultados

### Etapas del Pipeline

El pipeline ejecutará estas etapas en orden:

1. ✅ **Checkout** (~10 segundos)
   - Obtiene el código fuente del repositorio

2. ✅ **Build Phase 1** (~2 minutos)
   - Compila user-service y product-service en paralelo
   - Espera ver: "BUILD SUCCESS" para ambos

3. ✅ **Build Phase 2** (~2 minutos)
   - Compila favourite-service y order-service en paralelo
   - Espera ver: "BUILD SUCCESS" para ambos

4. ✅ **Build Phase 3** (~2 minutos)
   - Compila payment-service y shipping-service en paralelo
   - Espera ver: "BUILD SUCCESS" para ambos

5. ✅ **Verify Artifacts** (~5 segundos)
   - Verifica que se generaron 6 archivos JAR
   - Espera ver: "✓ user-service.jar exists", etc.

6. ✅ **Unit Tests** (~1-2 minutos)
   - Ejecuta todas las pruebas unitarias
   - Espera ver: "Tests run: X, Failures: 0, Errors: 0"

7. ✅ **Build Docker Images** (~3-5 minutos)
   - Construye 6 imágenes Docker
   - Espera ver: "Successfully built" para cada servicio

8. ✅ **Deploy to Kubernetes** (~30-60 segundos)
   - Despliega los 6 servicios en Kubernetes
   - Espera ver: "deployment.apps/xxx-service created/configured"

9. ✅ **Integration Tests** (~1 minuto)
   - Verifica que todos los servicios responden
   - Espera ver: "✓ user-service health check passed", etc.

### Tiempo Total Estimado

⏱️ **8-12 minutos** (dependiendo de tu computadora)

---

## PASO 6: Verificar el Despliegue

### 6.1 Ver los Pods en Kubernetes

Abre PowerShell y ejecuta:

```powershell
kubectl get pods -n ecommerce
```

**Resultado esperado**: Deberías ver **12 pods** (6 servicios × 2 réplicas):

```
NAME                                 READY   STATUS    RESTARTS   AGE
user-service-xxxxxxxxx-xxxxx         1/1     Running   0          2m
user-service-xxxxxxxxx-xxxxx         1/1     Running   0          2m
product-service-xxxxxxxxx-xxxxx      1/1     Running   0          2m
product-service-xxxxxxxxx-xxxxx      1/1     Running   0          2m
favourite-service-xxxxxxxxx-xxxxx    1/1     Running   0          2m
favourite-service-xxxxxxxxx-xxxxx    1/1     Running   0          2m
order-service-xxxxxxxxx-xxxxx        1/1     Running   0          2m
order-service-xxxxxxxxx-xxxxx        1/1     Running   0          2m
payment-service-xxxxxxxxx-xxxxx      1/1     Running   0          2m
payment-service-xxxxxxxxx-xxxxx      1/1     Running   0          2m
shipping-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
shipping-service-xxxxxxxxx-xxxxx     1/1     Running   0          2m
```

**Importante**: La columna `READY` debe mostrar `1/1` y `STATUS` debe ser `Running`

### 6.2 Ver los Servicios

```powershell
kubectl get services -n ecommerce
```

**Resultado esperado**: Deberías ver **6 servicios**:

```
NAME                TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
user-service        NodePort   10.x.x.x        <none>        8700:30700/TCP   2m
product-service     NodePort   10.x.x.x        <none>        8500:30500/TCP   2m
favourite-service   NodePort   10.x.x.x        <none>        8800:30800/TCP   2m
order-service       NodePort   10.x.x.x        <none>        8300:30300/TCP   2m
payment-service     NodePort   10.x.x.x        <none>        8400:30400/TCP   2m
shipping-service    NodePort   10.x.x.x        <none>        8600:30600/TCP   2m
```

### 6.3 Probar los Endpoints

Primero, obtén la IP de Minikube:

```powershell
minikube ip
```

Ejemplo de salida: `192.168.49.2`

Ahora prueba cada servicio (reemplaza `192.168.49.2` con TU IP de Minikube):

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

**Resultado esperado para CADA comando**:

```json
{"status":"UP"}
```

Si ves este mensaje en los 6 servicios: **¡ÉXITO COMPLETO!** 🎉

---

## PASO 7: Capturar Evidencia (Para el Taller)

### 7.1 Captura de Pantalla de Jenkins

1. En Jenkins, ve a la página del build exitoso
2. Captura pantalla mostrando:
   - Las 9 etapas en verde (✅)
   - El tiempo total de ejecución
   - El estado "SUCCESS"

### 7.2 Captura de Pantalla de Kubernetes

```powershell
kubectl get all -n ecommerce
```

Captura pantalla mostrando todos los recursos (pods, services, deployments)

### 7.3 Captura de Pantalla de Health Checks

Ejecuta:

```powershell
minikube ip
```

Luego abre en el navegador (reemplaza con tu IP):

- http://192.168.49.2:30700/actuator/health (User)
- http://192.168.49.2:30500/actuator/health (Product)
- http://192.168.49.2:30800/actuator/health (Favourite)
- http://192.168.49.2:30300/actuator/health (Order)
- http://192.168.49.2:30400/actuator/health (Payment)
- http://192.168.49.2:30600/actuator/health (Shipping)

Captura pantalla de los 6 mostrando `{"status":"UP"}`

---

## ❌ Si Algo Sale Mal

### El build falla en Jenkins

1. **Lee el error** en Console Output
2. **Identifica la etapa** que falló
3. **Revisa los logs** de esa etapa específica
4. **Verifica pre-requisitos**:
   ```powershell
   .\verify-jenkins-ready.ps1
   ```

### Los pods no inician (Status: Pending, CrashLoopBackOff, Error)

```powershell
# Ver detalles del pod problemático
kubectl describe pod <nombre-del-pod> -n ecommerce

# Ver logs del pod
kubectl logs <nombre-del-pod> -n ecommerce
```

Busca en los logs:
- `ImagePullBackOff`: La imagen Docker no existe → Reconstruir imágenes
- `CrashLoopBackOff`: La aplicación no inicia → Revisar configuración
- `Pending`: Falta recursos → Verificar límites de CPU/memoria

### Las imágenes Docker no se construyen

Verifica que Docker está corriendo:

```powershell
docker ps
```

Si no aparece nada o da error:
1. Abre Docker Desktop
2. Espera a que inicie completamente
3. Vuelve a ejecutar el pipeline

### Los endpoints no responden

```powershell
# Verificar que los pods están READY
kubectl get pods -n ecommerce

# Ver logs de un servicio específico
kubectl logs deployment/user-service -n ecommerce

# Ver eventos recientes
kubectl get events -n ecommerce --sort-by='.lastTimestamp'
```

### Reiniciar todo desde cero

Si nada funciona, reinicia el namespace:

```powershell
# Eliminar namespace y recursos
kubectl delete namespace ecommerce

# Recrear namespace
kubectl create namespace ecommerce

# Volver a ejecutar el pipeline en Jenkins
```

---

## ✅ Checklist Final

Antes de dar por completado, verifica:

- [ ] Pipeline ejecutado con éxito en Jenkins (todas las etapas ✅)
- [ ] 12 pods corriendo en Kubernetes (kubectl get pods -n ecommerce)
- [ ] 6 servicios NodePort creados (kubectl get svc -n ecommerce)
- [ ] 6 health checks responden con {"status":"UP"}
- [ ] Capturas de pantalla tomadas
- [ ] Documentación revisada

---

## 🎓 Entregables del Taller

Para completar esta parte del taller (15%), debes entregar:

1. **Código**:
   - Jenkinsfile-stage
   - 6 archivos YAML en k8s/
   - Scripts de automatización

2. **Evidencia**:
   - Capturas de pantalla de Jenkins (build exitoso)
   - Capturas de kubectl get all -n ecommerce
   - Capturas de health checks funcionando

3. **Documentación**:
   - GUIA-PIPELINE-STAGE-JENKINS.md
   - RESUMEN-PIPELINE-STAGE.md
   - Explicación de la arquitectura

---

## 📚 Recursos Adicionales

- `GUIA-PIPELINE-STAGE-JENKINS.md` - Guía detallada
- `PIPELINE-MICROSERVICIOS.md` - Documentación técnica
- `RESUMEN-PIPELINE-STAGE.md` - Resumen ejecutivo
- `verify-jenkins-ready.ps1` - Script de verificación

---

## 🚀 ¡Listo para Empezar!

Ahora ejecuta:

1. `.\verify-jenkins-ready.ps1` → Verificar
2. Abre http://localhost:8081 → Configurar
3. Click "Build Now" → Ejecutar
4. `kubectl get pods -n ecommerce` → Verificar
5. `curl http://<minikube-ip>:307xx/actuator/health` → Probar

**¡Mucha suerte!** 🎉
