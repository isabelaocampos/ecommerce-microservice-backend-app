package com.selimhorri.app.integration;

import com.selimhorri.app.dto.OrderDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas de Integración para Order Service
 * Validación de comunicación entre Order Service y otros microservicios
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("Order Service Integration Tests")
class OrderServiceIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired(required = false)
    private DiscoveryClient discoveryClient;

    @Test
    @DisplayName("Should create order successfully")
    void testCreateOrder() {
        // Given
        OrderDto newOrder = new OrderDto();
        newOrder.setOrderDesc("Integration Test Order");

        // When
        ResponseEntity<OrderDto> response = restTemplate.postForEntity(
            "/api/orders",
            newOrder,
            OrderDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getOrderDesc()).isEqualTo("Integration Test Order");
    }

    @Test
    @DisplayName("Should retrieve all orders")
    void testGetAllOrders() {
        // When
        ResponseEntity<OrderDto[]> response = restTemplate.getForEntity(
            "/api/orders",
            OrderDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
    }

    @Test
    @DisplayName("Should verify service registration with Eureka")
    void testServiceDiscoveryIntegration() {
        // When
        if (discoveryClient != null) {
            List<ServiceInstance> instances = discoveryClient.getInstances("order-service");
            
            // Then
            assertThat(instances).isNotEmpty();
            assertThat(instances.get(0).getServiceId()).isEqualToIgnoringCase("order-service");
        }
    }

    @Test
    @DisplayName("Should handle order processing workflow")
    void testOrderProcessingWorkflow() {
        // Given - Create order
        OrderDto newOrder = new OrderDto();
        newOrder.setOrderDesc("Workflow Test Order");

        // When - Create
        ResponseEntity<OrderDto> createResponse = restTemplate.postForEntity(
            "/api/orders",
            newOrder,
            OrderDto.class
        );

        Integer orderId = createResponse.getBody().getOrderId();

        // When - Retrieve
        ResponseEntity<OrderDto> getResponse = restTemplate.getForEntity(
            "/api/orders/" + orderId,
            OrderDto.class
        );

        // Then
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody()).isNotNull();
        assertThat(getResponse.getBody().getOrderId()).isEqualTo(orderId);
    }
}
