package com.selimhorri.app.integration;

import com.selimhorri.app.dto.ProductDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas de Integración para Product Service
 * Validación de interacción completa del servicio de productos
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("Product Service Integration Tests")
class ProductServiceIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @DisplayName("Should create product and verify inventory")
    void testCreateProductWithInventory() {
        // Given
        ProductDto newProduct = new ProductDto();
        newProduct.setProductTitle("Integration Test Product");
        newProduct.setSku("INT-TEST-001");
        newProduct.setPriceUnit(new BigDecimal("149.99"));
        newProduct.setQuantity(50);

        // When
        ResponseEntity<ProductDto> response = restTemplate.postForEntity(
            "/api/products",
            newProduct,
            ProductDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getProductTitle()).isEqualTo("Integration Test Product");
        assertThat(response.getBody().getQuantity()).isEqualTo(50);
    }

    @Test
    @DisplayName("Should get all products with correct data")
    void testGetAllProducts() {
        // When
        ResponseEntity<ProductDto[]> response = restTemplate.getForEntity(
            "/api/products",
            ProductDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
    }

    @Test
    @DisplayName("Should update product price")
    void testUpdateProductPrice() {
        // Given - Create product
        ProductDto product = new ProductDto();
        product.setProductTitle("Price Test Product");
        product.setPriceUnit(new BigDecimal("99.99"));
        product.setQuantity(100);

        ResponseEntity<ProductDto> createResponse = restTemplate.postForEntity(
            "/api/products",
            product,
            ProductDto.class
        );

        ProductDto createdProduct = createResponse.getBody();
        assertThat(createdProduct).isNotNull();

        // When - Update price
        createdProduct.setPriceUnit(new BigDecimal("79.99"));
        restTemplate.put("/api/products", createdProduct);

        // Then - Verify update
        ResponseEntity<ProductDto> getResponse = restTemplate.getForEntity(
            "/api/products/" + createdProduct.getProductId(),
            ProductDto.class
        );

        assertThat(getResponse.getBody()).isNotNull();
        assertThat(getResponse.getBody().getPriceUnit()).isEqualByComparingTo(new BigDecimal("79.99"));
    }

    @Test
    @DisplayName("Should handle product search by SKU")
    void testSearchProductBySku() {
        // Given
        ProductDto product = new ProductDto();
        product.setProductTitle("SKU Test Product");
        product.setSku("SKU-SEARCH-001");
        product.setPriceUnit(new BigDecimal("59.99"));

        restTemplate.postForEntity("/api/products", product, ProductDto.class);

        // When
        ResponseEntity<ProductDto[]> response = restTemplate.getForEntity(
            "/api/products?sku=SKU-SEARCH-001",
            ProductDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
