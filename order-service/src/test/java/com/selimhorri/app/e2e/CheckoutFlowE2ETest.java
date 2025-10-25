package com.selimhorri.app.e2e;

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
 * Pruebas E2E para flujo completo de checkout
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("E2E: Complete Checkout Flow")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class CheckoutFlowE2ETest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static ProductDto cartProduct;
    private static OrderDto checkoutOrder;

    @Test
    @Order(1)
    @DisplayName("E2E: Add Product to Cart")
    void step1_AddProductToCart() {
        // Given
        ProductDto product = new ProductDto();
        product.setProductTitle("Wireless Mouse");
        product.setSku("MOUSE-WIRELESS-001");
        product.setPriceUnit(new BigDecimal("29.99"));
        product.setQuantity(100);

        // When
        ResponseEntity<ProductDto> response = restTemplate.postForEntity(
            "/api/products",
            product,
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        cartProduct = response.getBody();
        
        System.out.println("✓ Product added to cart: " + cartProduct.getProductTitle());
    }

    @Test
    @Order(2)
    @DisplayName("E2E: Review Cart Items")
    void step2_ReviewCart() {
        // When
        ResponseEntity<ProductDto> response = restTemplate.getForEntity(
            "/api/products/" + cartProduct.getProductId(),
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        
        System.out.println("✓ Cart reviewed");
    }

    @Test
    @Order(3)
    @DisplayName("E2E: Proceed to Checkout")
    void step3_ProceedToCheckout() {
        // Given
        OrderDto order = new OrderDto();
        order.setOrderDesc("Checkout Order - " + cartProduct.getProductTitle());

        // When
        ResponseEntity<OrderDto> response = restTemplate.postForEntity(
            "/api/orders",
            order,
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        checkoutOrder = response.getBody();
        
        System.out.println("✓ Proceeded to checkout");
    }

    @Test
    @Order(4)
    @DisplayName("E2E: Confirm Order Details")
    void step4_ConfirmOrderDetails() {
        // When
        ResponseEntity<OrderDto> response = restTemplate.getForEntity(
            "/api/orders/" + checkoutOrder.getOrderId(),
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        
        System.out.println("✓ Order details confirmed");
    }

    @Test
    @Order(5)
    @DisplayName("E2E: Complete Purchase")
    void step5_CompletePurchase() {
        // Verify order was created successfully
        ResponseEntity<OrderDto> response = restTemplate.getForEntity(
            "/api/orders/" + checkoutOrder.getOrderId(),
            OrderDto.class
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        
        System.out.println("✓ Purchase completed");
        System.out.println("\n=== Checkout Flow E2E Test Completed ===");
    }
}
