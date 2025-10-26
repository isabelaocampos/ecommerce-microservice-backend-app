package com.selimhorri.app.e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * E2E Test: Product Service
 * Valida flujo completo de gestión de productos
 * 
 * PREREQUISITO: product-service debe estar corriendo en puerto 8500
 * Para ejecutar: mvn test -Dtest=ProductServiceE2ETest
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("E2E: Product Service Complete Flow")
class ProductServiceE2ETest {

    private static final String PRODUCT_SERVICE_URL = "http://localhost:8500";
    private static Integer testProductId;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = PRODUCT_SERVICE_URL;
        RestAssured.basePath = "/api/products";
    }

    @Test
    @Order(1)
    @DisplayName("E2E Step 1: Create new product")
    void testCreateProduct() {
        String sku = "E2E-PROD-" + System.currentTimeMillis();

        testProductId = given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"productTitle\": \"E2E Test Product\",\n" +
                "  \"imageUrl\": \"http://example.com/product.jpg\",\n" +
                "  \"sku\": \"" + sku + "\",\n" +
                "  \"priceUnit\": 99.99,\n" +
                "  \"quantity\": 50\n" +
                "}")
        .when()
            .post()
        .then()
            .statusCode(200)
            .body("productId", notNullValue())
            .body("productTitle", equalTo("E2E Test Product"))
            .body("sku", equalTo(sku))
        .extract()
            .path("productId");

        System.out.println("✓ Product created with ID: " + testProductId);
    }

    @Test
    @Order(2)
    @DisplayName("E2E Step 2: Retrieve product by ID")
    void testGetProduct() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .get("/" + testProductId)
        .then()
            .statusCode(200)
            .body("productId", equalTo(testProductId))
            .body("productTitle", equalTo("E2E Test Product"))
            .body("priceUnit", equalTo(99.99f));

        System.out.println("✓ Product retrieved successfully");
    }

    @Test
    @Order(3)
    @DisplayName("E2E Step 3: Update product information")
    void testUpdateProduct() {
        given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"productId\": " + testProductId + ",\n" +
                "  \"productTitle\": \"E2E Updated Product\",\n" +
                "  \"imageUrl\": \"http://example.com/updated.jpg\",\n" +
                "  \"sku\": \"UPDATED-SKU\",\n" +
                "  \"priceUnit\": 149.99,\n" +
                "  \"quantity\": 75\n" +
                "}")
        .when()
            .put()
        .then()
            .statusCode(200)
            .body("productTitle", equalTo("E2E Updated Product"))
            .body("priceUnit", equalTo(149.99f));

        System.out.println("✓ Product updated successfully");
    }

    @Test
    @Order(4)
    @DisplayName("E2E Step 4: List all products")
    void testGetAllProducts() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("collection", notNullValue())
            .body("collection.size()", greaterThan(0));

        System.out.println("✓ Retrieved all products successfully");
    }

    @Test
    @Order(5)
    @DisplayName("E2E Step 5: Delete product")
    void testDeleteProduct() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .delete("/" + testProductId)
        .then()
            .statusCode(200)
            .body(equalTo("true"));

        System.out.println("✓ Product deleted - E2E flow complete!");
    }
}
