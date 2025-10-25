package com.selimhorri.app.e2e;

import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.dto.OrderDto;
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
 * Pruebas E2E para flujo de gestión de inventario y órdenes
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("E2E: Product Inventory and Order Flow")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ProductInventoryOrderFlowE2ETest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static ProductDto testProduct;

    @Test
    @Order(1)
    @DisplayName("E2E: Add New Product to Inventory")
    void step1_AddProductToInventory() {
        // Given
        ProductDto newProduct = new ProductDto();
        newProduct.setProductTitle("Premium Laptop");
        newProduct.setSku("LAPTOP-001");
        newProduct.setPriceUnit(new BigDecimal("1299.99"));
        newProduct.setQuantity(20);
        newProduct.setImageUrl("http://example.com/laptop.jpg");

        // When
        ResponseEntity<ProductDto> response = restTemplate.postForEntity(
            "/api/products",
            newProduct,
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        testProduct = response.getBody();
        
        System.out.println("✓ Product added to inventory: " + testProduct.getProductTitle());
    }

    @Test
    @Order(2)
    @DisplayName("E2E: Verify Product Availability")
    void step2_VerifyProductAvailability() {
        // When
        ResponseEntity<ProductDto> response = restTemplate.getForEntity(
            "/api/products/" + testProduct.getProductId(),
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getQuantity()).isEqualTo(20);
        
        System.out.println("✓ Product availability verified: " + response.getBody().getQuantity() + " units");
    }

    @Test
    @Order(3)
    @DisplayName("E2E: Create Order with Product")
    void step3_CreateOrderWithProduct() {
        // Given
        OrderDto newOrder = new OrderDto();
        newOrder.setOrderDesc("Order for " + testProduct.getProductTitle());

        // When
        ResponseEntity<OrderDto> response = restTemplate.postForEntity(
            "/api/orders",
            newOrder,
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        
        System.out.println("✓ Order created for product");
    }

    @Test
    @Order(4)
    @DisplayName("E2E: Update Product Price")
    void step4_UpdateProductPrice() {
        // Given
        testProduct.setPriceUnit(new BigDecimal("1199.99"));

        // When
        restTemplate.put("/api/products", testProduct);

        // Then
        ResponseEntity<ProductDto> response = restTemplate.getForEntity(
            "/api/products/" + testProduct.getProductId(),
            ProductDto.class
        );

        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getPriceUnit()).isEqualByComparingTo(new BigDecimal("1199.99"));
        
        System.out.println("✓ Product price updated");
    }

    @Test
    @Order(5)
    @DisplayName("E2E: Search Products by Category")
    void step5_SearchProducts() {
        // When
        ResponseEntity<ProductDto[]> response = restTemplate.getForEntity(
            "/api/products",
            ProductDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotEmpty();
        
        System.out.println("✓ Product search completed");
        System.out.println("\n=== Inventory Flow E2E Test Completed ===");
    }
}
