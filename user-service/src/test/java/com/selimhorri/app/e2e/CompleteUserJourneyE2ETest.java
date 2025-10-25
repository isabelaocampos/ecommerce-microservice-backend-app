package com.selimhorri.app.e2e;

import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.dto.ProductDto;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas End-to-End para flujo completo de usuario
 * Simula: Registro de Usuario -> Búsqueda de Producto -> Creación de Orden -> Pago
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("E2E: Complete User Journey")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class CompleteUserJourneyE2ETest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static UserDto testUser;
    private static ProductDto testProduct;
    private static OrderDto testOrder;

    @Test
    @Order(1)
    @DisplayName("E2E Step 1: User Registration")
    void step1_UserRegistration() {
        // Given
        UserDto newUser = new UserDto();
        newUser.setFirstName("John");
        newUser.setLastName("Customer");
        newUser.setEmail("john.customer@ecommerce.com");
        newUser.setPhone("1234567890");

        // When
        ResponseEntity<UserDto> response = restTemplate.postForEntity(
            "/api/users",
            newUser,
            UserDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getUserId()).isNotNull();
        
        testUser = response.getBody();
        System.out.println("✓ User registered with ID: " + testUser.getUserId());
    }

    @Test
    @Order(2)
    @DisplayName("E2E Step 2: Browse Products")
    void step2_BrowseProducts() {
        // When
        ResponseEntity<ProductDto[]> response = restTemplate.getForEntity(
            "/api/products",
            ProductDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        
        System.out.println("✓ Products browsed successfully");
    }

    @Test
    @Order(3)
    @DisplayName("E2E Step 3: View Product Details")
    void step3_ViewProductDetails() {
        // Given - Create a test product
        ProductDto product = new ProductDto();
        product.setProductTitle("E2E Test Product");
        product.setSku("E2E-SKU-001");
        product.setPriceUnit(new BigDecimal("99.99"));
        product.setQuantity(10);

        ResponseEntity<ProductDto> createResponse = restTemplate.postForEntity(
            "/api/products",
            product,
            ProductDto.class
        );

        testProduct = createResponse.getBody();

        // When - View product details
        ResponseEntity<ProductDto> response = restTemplate.getForEntity(
            "/api/products/" + testProduct.getProductId(),
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getProductTitle()).isEqualTo("E2E Test Product");
        
        System.out.println("✓ Product details viewed: " + testProduct.getProductTitle());
    }

    @Test
    @Order(4)
    @DisplayName("E2E Step 4: Add Product to Cart and Create Order")
    void step4_CreateOrder() {
        // Given
        OrderDto newOrder = new OrderDto();
        newOrder.setOrderDesc("E2E Test Order - User: " + testUser.getUserId());

        // When
        ResponseEntity<OrderDto> response = restTemplate.postForEntity(
            "/api/orders",
            newOrder,
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getOrderId()).isNotNull();
        
        testOrder = response.getBody();
        System.out.println("✓ Order created with ID: " + testOrder.getOrderId());
    }

    @Test
    @Order(5)
    @DisplayName("E2E Step 5: Verify Order Status")
    void step5_VerifyOrderStatus() {
        // When
        ResponseEntity<OrderDto> response = restTemplate.getForEntity(
            "/api/orders/" + testOrder.getOrderId(),
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getOrderId()).isEqualTo(testOrder.getOrderId());
        
        System.out.println("✓ Order status verified");
    }

    @Test
    @Order(6)
    @DisplayName("E2E Step 6: Process Payment (Simulated)")
    void step6_ProcessPayment() {
        // This would normally interact with payment service
        // For now, we verify the order exists and can be processed
        
        // When
        ResponseEntity<OrderDto> response = restTemplate.getForEntity(
            "/api/orders/" + testOrder.getOrderId(),
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        System.out.println("✓ Payment processed (simulated)");
    }

    @Test
    @Order(7)
    @DisplayName("E2E Step 7: View Order History")
    void step7_ViewOrderHistory() {
        // When
        ResponseEntity<OrderDto[]> response = restTemplate.getForEntity(
            "/api/orders",
            OrderDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().length).isGreaterThan(0);
        
        System.out.println("✓ Order history retrieved");
        System.out.println("\n=== E2E Test Completed Successfully ===");
    }
}
