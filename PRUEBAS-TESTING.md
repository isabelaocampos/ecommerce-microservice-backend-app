# Pruebas Implementadas - Testing Suite

## Resumen General

Implementé las pruebas en los 3 microservicios principales (user, product, order) cubriendo todos los tipos requeridos:
- ✅ Pruebas Unitarias (>5)
- ✅ Pruebas de Integración (>5)
- ✅ Pruebas E2E (>5)
- ✅ Pruebas de Rendimiento con Locust

---

## 1. Pruebas Unitarias (11 total)

### User Service (6 pruebas)
**Archivo:** `user-service/src/test/java/com/selimhorri/app/service/UserServiceUnitTest.java`
1. `testFindAll_ShouldReturnListOfUsers()` - Validar obtención de todos los usuarios
2. `testFindById_WhenUserExists_ShouldReturnUser()` - Buscar usuario por ID existente
3. `testFindById_WhenUserDoesNotExist_ShouldThrowException()` - Manejo de usuario inexistente
4. `testSave_ShouldCreateNewUser()` - Creación de nuevo usuario
5. `testUpdate_WhenUserExists_ShouldUpdateUser()` - Actualización de usuario existente
6. `testDeleteById_ShouldRemoveUser()` - Eliminación de usuario

**Archivo:** `user-service/src/test/java/com/selimhorri/app/resource/UserResourceUnitTest.java`
- Tests de endpoints REST (GET, POST, PUT, DELETE) - **Arreglé los text blocks para Java 11**

### Product Service (5 pruebas)
**Archivo:** `product-service/src/test/java/com/selimhorri/app/service/ProductServiceUnitTest.java`
1. `testFindAll_ShouldReturnListOfProducts()` - Obtener todos los productos
2. `testFindById_WhenProductExists_ShouldReturnProduct()` - Buscar producto por ID
3. `testSave_ShouldCreateNewProduct()` - Crear nuevo producto
4. `testSave_WithNegativeQuantity_ShouldThrowException()` - Validación de cantidad negativa
5. `testDeleteById_ShouldRemoveProduct()` - Eliminar producto

### Order Service (3 pruebas)
**Archivo:** `order-service/src/test/java/com/selimhorri/app/service/OrderServiceUnitTest.java`
1. `testFindAll_ShouldReturnListOfOrders()` - Obtener todas las órdenes
2. `testFindById_WhenOrderExists_ShouldReturnOrder()` - Buscar orden por ID
3. `testSave_ShouldCreateNewOrder()` - Crear nueva orden

---

## 2. Pruebas de Integración (11 total)

### User Service (7 pruebas)
**Archivo:** `user-service/src/test/java/com/selimhorri/app/integration/UserServiceIntegrationTest.java`
1. `testCreateAndRetrieveUser()` - Flujo completo POST → GET
2. `testGetAllUsers()` - Endpoint GET /api/users
3. `testUpdateUser()` - Flujo POST → PUT → GET
4. `testDeleteUser()` - Flujo POST → DELETE → verificar 404
5. `testGetNonExistentUser()` - Manejo de recursos inexistentes

**Archivo:** `user-service/src/test/java/com/selimhorri/app/integration/CrossServiceIntegrationTest.java`
6. `testApiGatewayConnectivity()` - Conexión con API Gateway
7. `testServiceCommunicationThroughGateway()` - Comunicación entre servicios vía gateway

### Product Service (4 pruebas)
**Archivo:** `product-service/src/test/java/com/selimhorri/app/integration/ProductServiceIntegrationTest.java`
1. `testCreateProductWithInventory()` - Crear producto con validación de inventario
2. `testGetAllProducts()` - Obtener catálogo completo
3. `testUpdateProductPrice()` - Actualizar precio de producto
4. `testSearchProductBySku()` - Búsqueda por SKU

### Order Service (4 pruebas)
**Archivo:** `order-service/src/test/java/com/selimhorri/app/integration/OrderServiceIntegrationTest.java`
1. `testCreateOrder()` - Crear orden
2. `testGetAllOrders()` - Obtener todas las órdenes
3. `testServiceDiscoveryIntegration()` - Integración con Service Discovery (Eureka)
4. `testOrderProcessingWorkflow()` - Flujo completo de procesamiento de orden

---

## 3. Pruebas End-to-End (7 total)

### User Service E2E - User Profile Management (5 pasos)
**Archivo:** `user-service/src/test/java/com/selimhorri/app/e2e/UserProfileManagementE2ETest.java`

Flujo secuencial de gestión de perfil:
1. `step1_CreateUserAccount()` - Registro de cuenta
2. `step2_RetrieveUserProfile()` - Obtener perfil
3. `step3_UpdateUserProfile()` - Actualizar información
4. `step4_ListAllUsers()` - Listar usuarios
5. `step5_DeleteUserAccount()` - Eliminar cuenta

### User Service E2E - Complete User Journey (6+ pasos)
**Archivo:** `user-service/src/test/java/com/selimhorri/app/e2e/CompleteUserJourneyE2ETest.java`

Flujo completo de e-commerce:
1. `step1_UserRegistration()` - Registro de usuario
2. `step2_BrowseProducts()` - Navegación de catálogo
3. `step3_ViewProductDetails()` - Ver detalles de producto
4. `step4_CreateOrder()` - Crear orden
5. `step5_ProcessPayment()` - Procesar pago
6. `step6_TrackShipment()` - Rastrear envío

### Product Service E2E
**Archivo:** `product-service/src/test/java/com/selimhorri/app/e2e/ProductInventoryOrderFlowE2ETest.java`

Flujo de inventario y orden de productos

### Order Service E2E
**Archivo:** `order-service/src/test/java/com/selimhorri/app/e2e/CheckoutFlowE2ETest.java`

Flujo completo de checkout

---

## 4. Pruebas de Rendimiento (Locust)

**Archivo:** `locustfile.py`

### Usuarios Específicos por Servicio

1. **UserServiceUser** - Puerto 8700
   - GET /api/users (peso: 3)
   - GET /api/users/{id} (peso: 2)
   - POST /api/users (peso: 1)
   - PUT /api/users (peso: 1)

2. **ProductServiceUser** - Puerto 8500
   - GET /api/products (peso: 5)
   - GET /api/products/{id} (peso: 3)
   - POST /api/products (peso: 1)
   - Búsqueda de productos (peso: 2)

3. **OrderServiceUser** - Puerto 8300
   - GET /api/orders (peso: 3)
   - GET /api/orders/{id} (peso: 2)
   - POST /api/orders (peso: 2)

4. **PaymentServiceUser** - Puerto 8400
   - GET /api/payments (peso: 2)
   - POST /api/payments (peso: 1)

5. **ShippingServiceUser** - Puerto 8600
   - GET /api/shippings (peso: 2)
   - POST /api/shippings (peso: 1)

6. **FavouriteServiceUser** - Puerto 8800
   - GET /api/favourites (peso: 2)
   - POST /api/favourites (peso: 1)

### Flujos Completos

7. **CompleteJourneyUser** - Flujo secuencial completo
   - Registro → Navegación → Ver producto → Orden → Pago

8. **StressTestUser** - Pruebas de estrés
   - Ráfagas rápidas a todos los endpoints
   - `wait_time = between(0.1, 0.5)` para alta presión

### Comandos para Ejecutar

```powershell
# Prueba básica (100 usuarios, 5 minutos)
locust -f locustfile.py --headless -u 100 -r 10 -t 5m --html performance-report.html

# Prueba de estrés (500 usuarios, 10 minutos)
locust -f locustfile.py --headless -u 500 -r 50 -t 10m --html stress-report.html

# Modo interactivo (Web UI)
locust -f locustfile.py
# Abrir http://localhost:8089
```

### Escenarios de Prueba

1. **Carga Normal** - 100 usuarios concurrentes
2. **Pico de Tráfico** - 500 usuarios concurrentes
3. **Estrés Sostenido** - 1000 usuarios por 30 minutos
4. **Flujo Realista** - Usuarios siguiendo journey completo

---

## Cambios Realizados para Java 11

### Problema Encontrado
Los tests originales usaban **text blocks** (`"""..."""`) que son característica de Java 15+

### Solución Aplicada
Reemplacé los text blocks en `UserResourceUnitTest.java` por concatenación de strings tradicional:

**Antes (Java 15+):**
```java
String userJson = """
    {
        "firstName": "John",
        "lastName": "Doe"
    }
    """;
```

**Después (Java 11):**
```java
String userJson = "{\n" +
    "    \"firstName\": \"John\",\n" +
    "    \"lastName\": \"Doe\"\n" +
    "}";
```

---

## Ejecución de Pruebas

### Tests Unitarios e Integración
```powershell
# User Service
cd user-service
mvn test

# Product Service
cd product-service
mvn test

# Order Service
cd order-service
mvn test
```

### Tests E2E
```powershell
# Requiere servicios levantados
mvn test -Dtest=*E2ETest
```

### Tests de Rendimiento
```powershell
# Instalar Locust
pip install locust

# Ejecutar pruebas
locust -f locustfile.py --headless -u 100 -r 10 -t 5m --html performance-report.html
```

---

## Cobertura de Requisitos

✅ **5+ Pruebas Unitarias:** 11 implementadas
✅ **5+ Pruebas de Integración:** 11 implementadas
✅ **5+ Pruebas E2E:** 7+ implementadas (flujos secuenciales)
✅ **Pruebas de Rendimiento:** 8 perfiles de usuario + escenarios de carga

**Total:** 29+ pruebas automatizadas + suite completa de rendimiento con Locust
