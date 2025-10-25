# 🎯 Los 6 Microservicios del Proyecto

## Microservicios Principales (Los 6 del taller)

### 1. **user-service** 👥 (Puerto 8700)
- Gestión de usuarios
- Autenticación y autorización
- Perfiles de usuario
- Direcciones de usuario
- **Pruebas:** 
  - `UserServiceUnitTest.java`
  - `UserResourceUnitTest.java`
  - `UserServiceIntegrationTest.java`
  - `CompleteUserJourneyE2ETest.java`
  - `UserProfileManagementE2ETest.java`

### 2. **product-service** 📦 (Puerto 8500)
- Catálogo de productos
- Gestión de inventario
- Búsqueda de productos
- SKU y precios
- **Pruebas:**
  - `ProductServiceUnitTest.java`
  - `ProductServiceIntegrationTest.java`
  - `ProductInventoryOrderFlowE2ETest.java`

### 3. **favourite-service** ⭐ (Puerto 8800)
- Lista de favoritos/wishlist
- Productos marcados como favoritos
- Gestión de preferencias
- **Pruebas:**
  - Pruebas básicas incluidas en el servicio

### 4. **order-service** 🛒 (Puerto 8300)
- Procesamiento de órdenes
- Gestión del carrito
- Estado de órdenes
- Historial de compras
- **Pruebas:**
  - `OrderServiceUnitTest.java`
  - `OrderServiceIntegrationTest.java`
  - `CheckoutFlowE2ETest.java`

### 5. **payment-service** 💳 (Puerto 8400)
- Procesamiento de pagos
- Validación de transacciones
- Estado de pagos
- Métodos de pago
- **Pruebas:**
  - Pruebas básicas incluidas en el servicio

### 6. **shipping-service** 🚚 (Puerto 8600)
- Gestión de envíos
- Tracking de paquetes
- Información de entrega
- Proveedores de envío
- **Pruebas:**
  - Pruebas básicas incluidas en el servicio

---

## Servicios de Soporte (No cuentan en los 6)

### **api-gateway** 🌐 (Puerto 8080)
- Gateway principal
- Enrutamiento de requests
- Load balancing
- **No cuenta como microservicio del taller**

### **service-discovery** (Eureka) 🔍 (Puerto 8761)
- Service registry
- Service discovery
- Health checks
- **No cuenta como microservicio del taller**

### **zipkin** 📊 (Puerto 9411)
- Distributed tracing
- Monitoreo de requests
- Performance tracking
- **No cuenta como microservicio del taller**

---

## Comunicación entre Microservicios

```
Cliente → API Gateway → {
    user-service (Usuarios)
    ↓
    product-service (Productos)
    ↓
    favourite-service (Favoritos)
    ↓
    order-service (Órdenes) → payment-service (Pagos)
    ↓
    shipping-service (Envíos)
}
```

### Flujo de Ejemplo: Compra Completa

1. **User Service**: Usuario se registra/autentica
2. **Product Service**: Usuario busca productos
3. **Favourite Service**: Usuario marca productos favoritos (opcional)
4. **Order Service**: Usuario crea una orden
5. **Payment Service**: Se procesa el pago
6. **Shipping Service**: Se gestiona el envío

---

## Archivos de Kubernetes por Servicio

```
k8s/
├── user-service-deployment.yaml
├── product-service-deployment.yaml
├── favourite-service-deployment.yaml
├── order-service-deployment.yaml
├── payment-service-deployment.yaml
└── shipping-service-deployment.yaml
```

Cada deployment incluye:
- ✅ Deployment con 2 réplicas
- ✅ Service tipo LoadBalancer
- ✅ Health checks (liveness & readiness)
- ✅ Variables de entorno (Eureka, Zipkin)

---

## Verificación de los 6 Microservicios

```powershell
# Ver los 6 microservicios desplegados
kubectl get deployments -n ecommerce | Select-String "user-service|product-service|favourite-service|order-service|payment-service|shipping-service"

# Ver pods de los 6 microservicios
kubectl get pods -n ecommerce | Select-String "user-service|product-service|favourite-service|order-service|payment-service|shipping-service"

# Ver servicios expuestos
kubectl get services -n ecommerce | Select-String "user-service|product-service|favourite-service|order-service|payment-service|shipping-service"
```

---

## Pruebas por Microservicio

| Microservicio | Unitarias | Integración | E2E | Performance |
|---------------|-----------|-------------|-----|-------------|
| user-service | ✅ 11 | ✅ 5 | ✅ 12 | ✅ |
| product-service | ✅ 5 | ✅ 4 | ✅ 5 | ✅ |
| favourite-service | ✅ | - | - | ✅ |
| order-service | ✅ 3 | ✅ 4 | ✅ 5 | ✅ |
| payment-service | ✅ | - | - | ✅ |
| shipping-service | ✅ | - | - | ✅ |

**Total:** 19+ Unitarias, 13+ Integración, 22+ E2E

---

## Justificación de la Selección

Estos 6 microservicios fueron seleccionados porque:

1. ✅ **Se comunican entre sí** - Forman un flujo completo de e-commerce
2. ✅ **Representan funcionalidades core** - Usuarios, productos, órdenes, pagos
3. ✅ **Permiten pruebas end-to-end completas** - Flujos de usuario reales
4. ✅ **Tienen responsabilidades separadas** - Cada uno tiene su dominio
5. ✅ **Escalan independientemente** - 2 réplicas cada uno en Kubernetes
6. ✅ **Están completamente implementados** - Con pruebas y documentación

---

**Estos son los 6 microservicios del Taller 2** 🎓
