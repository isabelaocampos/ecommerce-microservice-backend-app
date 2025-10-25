"""
Locust Performance Testing Suite for E-Commerce Microservices
=============================================================

Este archivo contiene pruebas de rendimiento y estrés para los microservicios:
- User Service
- Product Service
- Order Service
- Payment Service
- Shipping Service
- Favourite Service

Uso:
    locust -f locustfile.py --headless -u 100 -r 10 -t 5m --html performance-report.html

Parámetros:
    -u: Número de usuarios concurrentes
    -r: Tasa de spawn (usuarios/segundo)
    -t: Duración del test
    --html: Generar reporte HTML
"""

from locust import HttpUser, task, between, tag, SequentialTaskSet
import json
import random

# =============================================================================
# CONFIGURACIÓN DE DATOS DE PRUEBA
# =============================================================================

SAMPLE_USERS = [
    {"firstName": "John", "lastName": "Doe", "email": f"john{i}@test.com", "phone": f"123456{i:04d}"}
    for i in range(100)
]

SAMPLE_PRODUCTS = [
    {"productTitle": "Laptop", "sku": "LAPTOP-001", "priceUnit": 1299.99, "quantity": 50},
    {"productTitle": "Mouse", "sku": "MOUSE-001", "priceUnit": 29.99, "quantity": 200},
    {"productTitle": "Keyboard", "sku": "KEYBOARD-001", "priceUnit": 79.99, "quantity": 150},
    {"productTitle": "Monitor", "sku": "MONITOR-001", "priceUnit": 399.99, "quantity": 100},
    {"productTitle": "Headphones", "sku": "HEADPHONE-001", "priceUnit": 149.99, "quantity": 120},
]


# =============================================================================
# CLASE BASE PARA TAREAS SECUENCIALES
# =============================================================================

class UserJourneyTasks(SequentialTaskSet):
    """
    Simula un flujo completo de usuario desde registro hasta compra
    """
    
    def on_start(self):
        """Inicialización antes de comenzar las tareas"""
        self.user_id = None
        self.product_id = None
        self.order_id = None
    
    @task
    def register_user(self):
        """Paso 1: Registro de usuario"""
        user_data = random.choice(SAMPLE_USERS).copy()
        user_data["email"] = f"user{random.randint(1000, 9999)}@test.com"
        
        with self.client.post("/api/users", 
                            json=user_data,
                            catch_response=True) as response:
            if response.status_code == 201:
                try:
                    self.user_id = response.json().get("userId")
                    response.success()
                except:
                    response.failure("Failed to parse user ID")
            else:
                response.failure(f"Got status code {response.status_code}")
    
    @task
    def browse_products(self):
        """Paso 2: Navegación de productos"""
        with self.client.get("/api/products", 
                           catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Got status code {response.status_code}")
    
    @task
    def view_product_details(self):
        """Paso 3: Ver detalles de un producto"""
        product_id = random.randint(1, 10)
        with self.client.get(f"/api/products/{product_id}",
                           catch_response=True) as response:
            if response.status_code in [200, 404]:
                self.product_id = product_id
                response.success()
            else:
                response.failure(f"Got status code {response.status_code}")
    
    @task
    def create_order(self):
        """Paso 4: Crear una orden"""
        if self.user_id and self.product_id:
            order_data = {
                "orderDesc": f"Order for user {self.user_id}",
                "orderDate": "2025-10-24T00:00:00"
            }
            
            with self.client.post("/api/orders",
                                json=order_data,
                                catch_response=True) as response:
                if response.status_code == 201:
                    try:
                        self.order_id = response.json().get("orderId")
                        response.success()
                    except:
                        response.failure("Failed to parse order ID")
                else:
                    response.failure(f"Got status code {response.status_code}")
    
    @task
    def view_order(self):
        """Paso 5: Ver orden creada"""
        if self.order_id:
            with self.client.get(f"/api/orders/{self.order_id}",
                               catch_response=True) as response:
                if response.status_code == 200:
                    response.success()
                else:
                    response.failure(f"Got status code {response.status_code}")


# =============================================================================
# USUARIOS ESPECÍFICOS POR SERVICIO
# =============================================================================

class UserServiceUser(HttpUser):
    """
    Usuario que interactúa principalmente con User Service
    """
    host = "http://localhost:8700"
    wait_time = between(1, 3)
    
    @tag('user-service', 'read')
    @task(3)
    def get_all_users(self):
        """GET /api/users - Obtener todos los usuarios"""
        self.client.get("/api/users")
    
    @tag('user-service', 'read')
    @task(2)
    def get_user_by_id(self):
        """GET /api/users/{id} - Obtener usuario por ID"""
        user_id = random.randint(1, 100)
        self.client.get(f"/api/users/{user_id}")
    
    @tag('user-service', 'write')
    @task(1)
    def create_user(self):
        """POST /api/users - Crear nuevo usuario"""
        user_data = random.choice(SAMPLE_USERS).copy()
        user_data["email"] = f"test{random.randint(1000, 9999)}@test.com"
        self.client.post("/api/users", json=user_data)
    
    @tag('user-service', 'write')
    @task(1)
    def update_user(self):
        """PUT /api/users - Actualizar usuario"""
        user_id = random.randint(1, 100)
        user_data = random.choice(SAMPLE_USERS).copy()
        user_data["userId"] = user_id
        self.client.put("/api/users", json=user_data)


class ProductServiceUser(HttpUser):
    """
    Usuario que interactúa principalmente con Product Service
    """
    host = "http://localhost:8500"
    wait_time = between(1, 3)
    
    @tag('product-service', 'read')
    @task(5)
    def get_all_products(self):
        """GET /api/products - Obtener todos los productos"""
        self.client.get("/api/products")
    
    @tag('product-service', 'read')
    @task(3)
    def get_product_by_id(self):
        """GET /api/products/{id} - Obtener producto por ID"""
        product_id = random.randint(1, 50)
        self.client.get(f"/api/products/{product_id}")
    
    @tag('product-service', 'write')
    @task(1)
    def create_product(self):
        """POST /api/products - Crear nuevo producto"""
        product_data = random.choice(SAMPLE_PRODUCTS).copy()
        product_data["sku"] = f"SKU-{random.randint(1000, 9999)}"
        self.client.post("/api/products", json=product_data)
    
    @tag('product-service', 'read')
    @task(2)
    def search_products(self):
        """Búsqueda de productos (simulada con GET all)"""
        self.client.get("/api/products")


class OrderServiceUser(HttpUser):
    """
    Usuario que interactúa principalmente con Order Service
    """
    host = "http://localhost:8300"
    wait_time = between(1, 3)
    
    @tag('order-service', 'read')
    @task(3)
    def get_all_orders(self):
        """GET /api/orders - Obtener todas las órdenes"""
        self.client.get("/api/orders")
    
    @tag('order-service', 'read')
    @task(2)
    def get_order_by_id(self):
        """GET /api/orders/{id} - Obtener orden por ID"""
        order_id = random.randint(1, 100)
        self.client.get(f"/api/orders/{order_id}")
    
    @tag('order-service', 'write')
    @task(2)
    def create_order(self):
        """POST /api/orders - Crear nueva orden"""
        order_data = {
            "orderDesc": f"Test Order {random.randint(1000, 9999)}",
            "orderDate": "2025-10-24T00:00:00"
        }
        self.client.post("/api/orders", json=order_data)


class PaymentServiceUser(HttpUser):
    """
    Usuario que interactúa con Payment Service
    """
    host = "http://localhost:8400"
    wait_time = between(1, 3)
    
    @tag('payment-service', 'read')
    @task(2)
    def get_all_payments(self):
        """GET /api/payments - Obtener todos los pagos"""
        self.client.get("/api/payments")
    
    @tag('payment-service', 'write')
    @task(1)
    def create_payment(self):
        """POST /api/payments - Crear nuevo pago"""
        payment_data = {
            "isPayed": True,
            "paymentStatus": "COMPLETED"
        }
        self.client.post("/api/payments", json=payment_data)


class ShippingServiceUser(HttpUser):
    """
    Usuario que interactúa con Shipping Service
    """
    host = "http://localhost:8600"
    wait_time = between(1, 3)
    
    @tag('shipping-service', 'read')
    @task(2)
    def get_all_shipments(self):
        """GET /api/shippings - Obtener todos los envíos"""
        self.client.get("/api/shippings")
    
    @tag('shipping-service', 'write')
    @task(1)
    def create_shipment(self):
        """POST /api/shippings - Crear nuevo envío"""
        shipping_data = {
            "shippingDate": "2025-10-24T00:00:00"
        }
        self.client.post("/api/shippings", json=shipping_data)


class FavouriteServiceUser(HttpUser):
    """
    Usuario que interactúa con Favourite Service
    """
    host = "http://localhost:8800"
    wait_time = between(1, 3)
    
    @tag('favourite-service', 'read')
    @task(2)
    def get_all_favourites(self):
        """GET /api/favourites - Obtener todos los favoritos"""
        self.client.get("/api/favourites")
    
    @tag('favourite-service', 'write')
    @task(1)
    def add_favourite(self):
        """POST /api/favourites - Agregar a favoritos"""
        favourite_data = {
            "likeDate": "2025-10-24T00:00:00"
        }
        self.client.post("/api/favourites", json=favourite_data)


# =============================================================================
# USUARIO DE FLUJO COMPLETO
# =============================================================================

class CompleteJourneyUser(HttpUser):
    """
    Usuario que ejecuta un flujo completo de e-commerce
    """
    host = "http://localhost:8080"  # API Gateway
    wait_time = between(2, 5)
    tasks = [UserJourneyTasks]


# =============================================================================
# USUARIO DE ESTRÉS (HIGH LOAD)
# =============================================================================

class StressTestUser(HttpUser):
    """
    Usuario para pruebas de estrés con alta carga
    """
    host = "http://localhost:8080"  # API Gateway
    wait_time = between(0.1, 0.5)  # Menor tiempo de espera para más presión
    
    @task(10)
    def rapid_fire_requests(self):
        """Ráfaga rápida de requests"""
        endpoints = [
            "/api/users",
            "/api/products",
            "/api/orders",
            "/api/payments",
            "/api/shippings",
            "/api/favourites"
        ]
        endpoint = random.choice(endpoints)
        self.client.get(endpoint)


# =============================================================================
# CONFIGURACIÓN DE EVENTOS PERSONALIZADOS
# =============================================================================

from locust import events

@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Se ejecuta cuando comienza el test"""
    print("\n" + "="*80)
    print("🚀 INICIANDO PRUEBAS DE RENDIMIENTO DE E-COMMERCE")
    print("="*80 + "\n")

@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Se ejecuta cuando termina el test"""
    print("\n" + "="*80)
    print("✅ PRUEBAS DE RENDIMIENTO COMPLETADAS")
    print("="*80 + "\n")
    print("📊 Resultados guardados en: performance-report.html")
    print("\n")
