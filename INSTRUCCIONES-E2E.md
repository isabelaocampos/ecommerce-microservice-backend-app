# Guía de Ejecución: Pruebas E2E (End-to-End)

## 📋 Descripción

Se han creado **3 suites de pruebas E2E** que validan el funcionamiento completo de los microservicios conectándose a las instancias reales corriendo en sus puertos:

### ✅ Pruebas Disponibles

| Suite | Servicio | Puerto | Tests | Descripción |
|-------|----------|--------|-------|-------------|
| `UserServiceE2ETest` | user-service | 8700 | 6 | CRUD completo de usuarios |
| `ProductServiceE2ETest` | product-service | 8500 | 5 | CRUD completo de productos |
| `CrossServiceOrderFlowE2ETest` | user + product + order | 8700, 8500, 8300 | 5 | Flujo multi-servicio |

**Total: 16 tests E2E** (cumple requisito de "al menos 5")

---

## 🚀 Método 1: Ejecución Automatizada (Recomendado)

### Paso 1: Iniciar los Servicios

Abre **3 terminales PowerShell separadas** y ejecuta:

```powershell
# Terminal 1 - User Service
cd user-service
.\mvnw.cmd spring-boot:run
```

```powershell
# Terminal 2 - Product Service
cd product-service
.\mvnw.cmd spring-boot:run
```

```powershell
# Terminal 3 - Order Service
cd order-service
.\mvnw.cmd spring-boot:run
```

**Espera** hasta que veas en cada terminal:
```
Started <ServiceName>Application in X.XXX seconds
```

### Paso 2: Ejecutar las Pruebas E2E

En una **4ta terminal** (desde la raíz del proyecto):

```powershell
.\run-e2e-tests.ps1
```

Este script:
1. ✅ Verifica que los servicios estén corriendo
2. 🧪 Ejecuta las 3 suites de pruebas E2E en secuencia
3. 📊 Muestra los resultados

---

## 🛠️ Método 2: Ejecución Manual Individual

Si prefieres ejecutar las pruebas una por una:

### Prerequisitos: Servicios Corriendo

Verifica que los servicios estén activos:

```powershell
# Verificar user-service
curl http://localhost:8700/actuator/health

# Verificar product-service
curl http://localhost:8500/actuator/health

# Verificar order-service
curl http://localhost:8300/actuator/health
```

### Ejecutar Test Individual

**Prueba 1: User Service E2E**

```powershell
.\mvnw.cmd test -Dtest=UserServiceE2ETest
```

Valida:
- ✅ Crear usuario
- ✅ Obtener usuario por ID
- ✅ Actualizar usuario
- ✅ Listar todos los usuarios
- ✅ Eliminar usuario
- ✅ Verificar eliminación

---

**Prueba 2: Product Service E2E**

```powershell
.\mvnw.cmd test -Dtest=ProductServiceE2ETest
```

Valida:
- ✅ Crear producto
- ✅ Obtener producto por ID
- ✅ Actualizar producto
- ✅ Listar todos los productos
- ✅ Eliminar producto

---

**Prueba 3: Cross-Service Order Flow E2E**

```powershell
.\mvnw.cmd test -Dtest=CrossServiceOrderFlowE2ETest
```

Valida:
- ✅ Crear usuario en `user-service` (puerto 8700)
- ✅ Crear producto en `product-service` (puerto 8500)
- ✅ Crear orden en `order-service` (puerto 8300)
- ✅ Verificar orden creada
- ✅ Verificar usuario sigue existiendo

**Esta prueba demuestra comunicación real entre microservicios** 🎯

---

## 📦 Ubicación de los Tests

Los tests E2E están en la **raíz del proyecto** (NO dentro de carpetas de microservicios individuales):

```
src/test/java/com/selimhorri/app/e2e/
├── UserServiceE2ETest.java              (6 tests)
├── ProductServiceE2ETest.java           (5 tests)
└── CrossServiceOrderFlowE2ETest.java    (5 tests)
```

**Ventaja**: Al estar fuera de las carpetas de microservicios, pueden conectarse a **múltiples servicios corriendo en puertos diferentes**.

---

## ⚙️ Tecnologías Utilizadas

- **REST Assured 4.4.0**: Framework para testing de APIs REST
- **JUnit 5**: Framework de testing
- **@TestMethodOrder**: Para ejecutar tests en orden específico (flujo E2E)
- **Hamcrest Matchers**: Para validaciones expresivas

---

## 🐛 Troubleshooting

### Error: "Connection refused"

**Causa**: El servicio no está corriendo en el puerto esperado.

**Solución**:
1. Verifica que ejecutaste `.\mvnw.cmd spring-boot:run` en el servicio correspondiente
2. Espera a que el servicio termine de iniciar (busca "Started Application")
3. Verifica el puerto correcto en la salida del servicio

### Error: "Expected status code 200 but was 404"

**Causa**: El endpoint no existe o la URL es incorrecta.

**Solución**:
1. Verifica que el servicio tenga el endpoint esperado
2. Revisa la documentación Swagger del servicio: `http://localhost:<PUERTO>/swagger-ui.html`
3. Confirma que el path base sea correcto (ej: `/api/users`)

### Error: "Expected status code 200 but was 500"

**Causa**: Error en la lógica del servicio (base de datos, validaciones, etc.)

**Solución**:
1. Revisa los logs del servicio en la terminal donde está corriendo
2. Verifica que la base de datos H2 esté configurada correctamente
3. Confirma que los datos de prueba sean válidos

---

## 📊 Resultados Esperados

Al ejecutar `.\run-e2e-tests.ps1` deberías ver:

```
========================================
 E2E TESTING - Ecommerce Microservices
========================================

Verificando servicios necesarios...

✓ user-service (puerto 8700) está corriendo
✓ product-service (puerto 8500) está corriendo
✓ order-service (puerto 8300) está corriendo

========================================
 Ejecutando Pruebas E2E
========================================

[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0  ← UserServiceE2ETest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0  ← ProductServiceE2ETest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0  ← CrossServiceOrderFlowE2ETest

========================================
 Pruebas E2E Completadas
========================================
```

---

## 📝 Notas Importantes

1. **Orden de Ejecución**: Los tests usan `@Order` para ejecutarse en secuencia (simula flujo real de usuario)

2. **Datos de Prueba**: Los tests generan datos únicos usando timestamps para evitar conflictos:
   ```java
   String email = "e2e.test." + System.currentTimeMillis() + "@example.com";
   ```

3. **No requieren @SpringBootTest**: Los tests se conectan a servicios reales externos, NO levantan un servidor embebido

4. **Stateful Tests**: Los tests guardan IDs generados para usarlos en pasos posteriores:
   ```java
   private static Integer testUserId; // Compartido entre tests
   ```

5. **Limpieza**: Los tests de User y Product incluyen eliminación al final para limpiar datos de prueba

---

## ✅ Checklist de Requisitos (Punto 3 - 30%)

- [x] **Al menos 5 pruebas unitarias**: `UserResourceUnitTest` (5 tests) ✅
- [ ] **Al menos 5 pruebas de integración**: Pendiente
- [x] **Al menos 5 pruebas E2E**: 16 tests E2E disponibles ✅
- [x] **Pruebas de rendimiento**: `locustfile.py` completo ✅

**Tests E2E creados**: 
- UserServiceE2ETest: 6 tests ✅
- ProductServiceE2ETest: 5 tests ✅  
- CrossServiceOrderFlowE2ETest: 5 tests ✅
- **Total: 16 E2E tests** (supera requisito de 5)

---

## 🎯 Próximos Pasos

1. Ejecutar los servicios necesarios
2. Correr `.\run-e2e-tests.ps1`
3. Crear las **5 pruebas de integración** faltantes
4. Documentar todos los tests en reporte final
