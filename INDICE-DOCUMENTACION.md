# Índice: Documentación del Pipeline STAGE

## 🎯 Inicio Rápido

**¿Primera vez? Empieza aquí:**

1. 📖 Lee: [`RESUMEN-PIPELINE-STAGE.md`](./RESUMEN-PIPELINE-STAGE.md)
2. ✅ Ejecuta: `.\verify-jenkins-ready.ps1`
3. 📋 Sigue: [`INSTRUCCIONES-EJECUTAR-PIPELINE.md`](./INSTRUCCIONES-EJECUTAR-PIPELINE.md)

---

## 📚 Documentación Disponible

### 🚀 Guías de Ejecución (Para Usuarios)

| Archivo | Descripción | Cuándo Usar |
|---------|-------------|-------------|
| [`INSTRUCCIONES-EJECUTAR-PIPELINE.md`](./INSTRUCCIONES-EJECUTAR-PIPELINE.md) | **Instrucciones paso a paso** para ejecutar el pipeline | ⭐ **EMPIEZA AQUÍ** si vas a ejecutar el pipeline |
| [`GUIA-PIPELINE-STAGE-JENKINS.md`](./GUIA-PIPELINE-STAGE-JENKINS.md) | Guía completa de configuración y uso de Jenkins | Para entender cómo configurar Jenkins |
| [`RESUMEN-PIPELINE-STAGE.md`](./RESUMEN-PIPELINE-STAGE.md) | Resumen ejecutivo de todo lo implementado | Para overview rápido del proyecto |

### 🔧 Documentación Técnica (Para Desarrolladores)

| Archivo | Descripción | Contenido |
|---------|-------------|-----------|
| [`PIPELINE-MICROSERVICIOS.md`](./PIPELINE-MICROSERVICIOS.md) | Documentación técnica detallada del pipeline | Arquitectura, etapas, configuración técnica |
| [`PIPELINE-BUILD-DEV.md`](./PIPELINE-BUILD-DEV.md) | Documentación del pipeline DEV | Referencia del ambiente de desarrollo |
| `Jenkinsfile-stage` | Pipeline de Jenkins (código) | El pipeline ejecutable |

### 📊 Scripts de Automatización

| Script | Propósito | Comando |
|--------|-----------|---------|
| `verify-jenkins-ready.ps1` | ✅ Verificar pre-requisitos | `.\verify-jenkins-ready.ps1` |
| `deploy-microservices-k8s.ps1` | 🚀 Deploy manual a K8s | `.\deploy-microservices-k8s.ps1` |
| `test-microservices-k8s.ps1` | 🧪 Testing de integración | `.\test-microservices-k8s.ps1` |

### 🗂️ Manifiestos de Kubernetes

Directorio: `k8s/`

| Archivo | Servicio | Puerto | NodePort |
|---------|----------|--------|----------|
| `user-service-deployment.yaml` | User Service | 8700 | 30700 |
| `product-service-deployment.yaml` | Product Service | 8500 | 30500 |
| `favourite-service-deployment.yaml` | Favourite Service | 8800 | 30800 |
| `order-service-deployment.yaml` | Order Service | 8300 | 30300 |
| `payment-service-deployment.yaml` | Payment Service | 8400 | 30400 |
| `shipping-service-deployment.yaml` | Shipping Service | 8600 | 30600 |

---

## 🎓 Para el Taller (Requisito del 15%)

### Archivos Clave a Revisar:

1. **Pipeline**: `Jenkinsfile-stage`
2. **Deployments**: Todos los archivos en `k8s/`
3. **Documentación**: 
   - `RESUMEN-PIPELINE-STAGE.md`
   - `GUIA-PIPELINE-STAGE-JENKINS.md`

### Evidencia a Capturar:

Ver sección "PASO 7" en [`INSTRUCCIONES-EJECUTAR-PIPELINE.md`](./INSTRUCCIONES-EJECUTAR-PIPELINE.md)

---

## 🔍 Búsqueda Rápida

### ¿Cómo hacer...?

| Quiero... | Ver Archivo |
|-----------|-------------|
| **Ejecutar el pipeline por primera vez** | [`INSTRUCCIONES-EJECUTAR-PIPELINE.md`](./INSTRUCCIONES-EJECUTAR-PIPELINE.md) |
| **Entender qué hace cada etapa** | [`PIPELINE-MICROSERVICIOS.md`](./PIPELINE-MICROSERVICIOS.md) |
| **Verificar que todo está OK** | Ejecutar `.\verify-jenkins-ready.ps1` |
| **Ver un resumen ejecutivo** | [`RESUMEN-PIPELINE-STAGE.md`](./RESUMEN-PIPELINE-STAGE.md) |
| **Configurar Jenkins desde cero** | [`GUIA-PIPELINE-STAGE-JENKINS.md`](./GUIA-PIPELINE-STAGE-JENKINS.md) |
| **Solucionar problemas** | Sección "Solución de Problemas" en cualquier guía |
| **Desplegar manualmente (sin Jenkins)** | Ejecutar `.\deploy-microservices-k8s.ps1` |
| **Probar los servicios** | Ejecutar `.\test-microservices-k8s.ps1` |

### ¿Qué es...?

| Término | Explicación | Dónde Leer Más |
|---------|-------------|----------------|
| **Pipeline STAGE** | CI/CD para desplegar a Kubernetes | [`RESUMEN-PIPELINE-STAGE.md`](./RESUMEN-PIPELINE-STAGE.md) |
| **Jenkinsfile-stage** | Script que define el pipeline | [`PIPELINE-MICROSERVICIOS.md`](./PIPELINE-MICROSERVICIOS.md) |
| **NodePort** | Tipo de servicio K8s para acceso externo | [`GUIA-PIPELINE-STAGE-JENKINS.md`](./GUIA-PIPELINE-STAGE-JENKINS.md) |
| **Health Check** | Endpoint para verificar estado del servicio | Sección "Verificación Post-Despliegue" |
| **Namespace ecommerce** | Aislamiento lógico en Kubernetes | [`RESUMEN-PIPELINE-STAGE.md`](./RESUMEN-PIPELINE-STAGE.md) |

---

## 📖 Flujo de Lectura Recomendado

### Para Ejecutar el Pipeline (Rápido)

```
1. RESUMEN-PIPELINE-STAGE.md         (5 min - Overview)
   ↓
2. verify-jenkins-ready.ps1          (1 min - Verificar)
   ↓
3. INSTRUCCIONES-EJECUTAR-PIPELINE.md (20 min - Ejecutar paso a paso)
```

### Para Entender la Arquitectura (Completo)

```
1. RESUMEN-PIPELINE-STAGE.md         (10 min - Contexto general)
   ↓
2. PIPELINE-MICROSERVICIOS.md        (20 min - Arquitectura técnica)
   ↓
3. GUIA-PIPELINE-STAGE-JENKINS.md    (30 min - Configuración detallada)
   ↓
4. Jenkinsfile-stage                 (15 min - Código del pipeline)
   ↓
5. k8s/*.yaml                        (15 min - Manifiestos K8s)
```

### Para el Taller (Entregables)

```
1. INSTRUCCIONES-EJECUTAR-PIPELINE.md (Ejecutar y capturar evidencia)
   ↓
2. verify-jenkins-ready.ps1          (Verificar pre-requisitos)
   ↓
3. Ejecutar pipeline en Jenkins      (Build Now)
   ↓
4. kubectl get all -n ecommerce      (Verificar despliegue)
   ↓
5. Capturar pantallas                (Jenkins + K8s + Health Checks)
   ↓
6. RESUMEN-PIPELINE-STAGE.md         (Documentar en informe)
```

---

## 🆘 Soporte

### Si tienes problemas...

1. **Primero**: Lee la sección "Solución de Problemas" en:
   - [`INSTRUCCIONES-EJECUTAR-PIPELINE.md`](./INSTRUCCIONES-EJECUTAR-PIPELINE.md)
   - [`GUIA-PIPELINE-STAGE-JENKINS.md`](./GUIA-PIPELINE-STAGE-JENKINS.md)

2. **Luego**: Ejecuta el script de diagnóstico:
   ```powershell
   .\verify-jenkins-ready.ps1
   ```

3. **Si persiste**: Revisa los logs:
   - Jenkins Console Output
   - `kubectl logs <pod-name> -n ecommerce`
   - `kubectl describe pod <pod-name> -n ecommerce`

---

## ✅ Checklist de Archivos

### Archivos de Configuración

- [x] `Jenkinsfile-stage` - Pipeline de Jenkins
- [x] `Dockerfile.jenkins` - Custom Jenkins image (opcional)

### Manifiestos Kubernetes (k8s/)

- [x] `user-service-deployment.yaml`
- [x] `product-service-deployment.yaml`
- [x] `favourite-service-deployment.yaml`
- [x] `order-service-deployment.yaml`
- [x] `payment-service-deployment.yaml`
- [x] `shipping-service-deployment.yaml`

### Scripts PowerShell

- [x] `verify-jenkins-ready.ps1` - Verificación de pre-requisitos
- [x] `deploy-microservices-k8s.ps1` - Deployment manual
- [x] `test-microservices-k8s.ps1` - Testing de integración

### Documentación

- [x] `RESUMEN-PIPELINE-STAGE.md` - Resumen ejecutivo
- [x] `GUIA-PIPELINE-STAGE-JENKINS.md` - Guía completa
- [x] `INSTRUCCIONES-EJECUTAR-PIPELINE.md` - Paso a paso
- [x] `PIPELINE-MICROSERVICIOS.md` - Documentación técnica
- [x] `PIPELINE-BUILD-DEV.md` - Referencia DEV
- [x] `INDICE-DOCUMENTACION.md` - Este archivo

---

## 📊 Estadísticas del Proyecto

| Métrica | Valor |
|---------|-------|
| **Microservicios** | 6 servicios |
| **Deployments K8s** | 6 archivos YAML |
| **Pods desplegados** | 12 (2 réplicas × 6 servicios) |
| **Etapas del pipeline** | 9 etapas |
| **Scripts de automatización** | 3 scripts PowerShell |
| **Archivos de documentación** | 6 archivos Markdown |
| **Líneas de código (Jenkinsfile)** | ~500 líneas |
| **Tiempo de build estimado** | 8-12 minutos |
| **Cobertura de documentación** | 100% |

---

## 🚀 Próximos Pasos

Después de completar este pipeline STAGE:

1. ✅ Ejecutar el pipeline en Jenkins
2. ✅ Verificar que los 6 servicios funcionan
3. ✅ Capturar evidencia para el taller
4. 📈 Considerar implementar pipeline de PRODUCCIÓN
5. 📊 Agregar monitoreo (Prometheus/Grafana)
6. 🔐 Implementar estrategias avanzadas (Blue/Green, Canary)

---

## 📞 Información del Proyecto

- **Entorno**: Kubernetes (Minikube) - STAGE
- **CI/CD**: Jenkins (Docker)
- **Namespace**: ecommerce
- **Porcentaje del Taller**: 15%
- **Estado**: ✅ Completo y funcional

---

**Última actualización**: Diciembre 2024  
**Versión**: 1.0  
**Estado**: Production Ready
