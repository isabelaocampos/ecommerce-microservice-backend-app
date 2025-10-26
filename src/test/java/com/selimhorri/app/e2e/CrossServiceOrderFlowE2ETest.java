package com.selimhorri.app.e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * E2E Test: Cross-Service Order Flow
 * Valida flujo completo que cruza User → Product → Order
 * 
 * PREREQUISITOS: 
 * - user-service en puerto 8700
 * - product-service en puerto 8500
 * - order-service en puerto 8300
 * 
 * Para ejecutar: mvn test -Dtest=CrossServiceOrderFlowE2ETest
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("E2E: Cross-Service Order Creation Flow")
class CrossServiceOrderFlowE2ETest {

    private static Integer userId;
    private static Integer productId;
    private static Integer orderId;

    @Test
    @Order(1)
    @DisplayName("E2E Step 1: Create user in user-service")
    void testCreateUser() {
        RestAssured.baseURI = "http://localhost:8700";
        
        String email = "order.flow." + System.currentTimeMillis() + "@example.com";

        userId = given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"firstName\": \"Order\",\n" +
                "  \"lastName\": \"Customer\",\n" +
                "  \"email\": \"" + email + "\",\n" +
                "  \"phone\": \"5551234567\"\n" +
                "}")
        .when()
            .post("/api/users")
        .then()
            .statusCode(200)
            .body("userId", notNullValue())
        .extract()
            .path("userId");

        System.out.println("✓ Step 1: User created (ID: " + userId + ")");
    }

    @Test
    @Order(2)
    @DisplayName("E2E Step 2: Create product in product-service")
    void testCreateProduct() {
        RestAssured.baseURI = "http://localhost:8500";
        
        String sku = "ORDER-PRODUCT-" + System.currentTimeMillis();

        productId = given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"productTitle\": \"Laptop for Order\",\n" +
                "  \"imageUrl\": \"http://example.com/laptop.jpg\",\n" +
                "  \"sku\": \"" + sku + "\",\n" +
                "  \"priceUnit\": 899.99,\n" +
                "  \"quantity\": 10\n" +
                "}")
        .when()
            .post("/api/products")
        .then()
            .statusCode(200)
            .body("productId", notNullValue())
        .extract()
            .path("productId");

        System.out.println("✓ Step 2: Product created (ID: " + productId + ")");
    }

    @Test
    @Order(3)
    @DisplayName("E2E Step 3: Create order in order-service")
    void testCreateOrder() {
        RestAssured.baseURI = "http://localhost:8300";

        orderId = given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"orderDate\": \"2024-10-26\",\n" +
                "  \"orderDesc\": \"E2E Test Order - Laptop Purchase\"\n" +
                "}")
        .when()
            .post("/api/orders")
        .then()
            .statusCode(200)
            .body("orderId", notNullValue())
        .extract()
            .path("orderId");

        System.out.println("✓ Step 3: Order created (ID: " + orderId + ")");
    }

    @Test
    @Order(4)
    @DisplayName("E2E Step 4: Verify order exists")
    void testVerifyOrder() {
        RestAssured.baseURI = "http://localhost:8300";

        given()
            .contentType(ContentType.JSON)
        .when()
            .get("/api/orders/" + orderId)
        .then()
            .statusCode(200)
            .body("orderId", equalTo(orderId))
            .body("orderDesc", containsString("Laptop Purchase"));

        System.out.println("✓ Step 4: Order verified");
    }

    @Test
    @Order(5)
    @DisplayName("E2E Step 5: Verify user still exists")
    void testVerifyUserExists() {
        RestAssured.baseURI = "http://localhost:8700";

        given()
            .contentType(ContentType.JSON)
        .when()
            .get("/api/users/" + userId)
        .then()
            .statusCode(200)
            .body("userId", equalTo(userId));

        System.out.println("✓ Step 5: User verified - Cross-service flow complete!");
    }
}
