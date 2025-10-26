package com.selimhorri.app.e2e;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

/**
 * E2E Test: User Service
 * Valida flujo completo de gestión de usuarios conectándose al servicio real
 * 
 * PREREQUISITO: user-service debe estar corriendo en puerto 8700
 * Para ejecutar: mvn test -Dtest=UserServiceE2ETest
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("E2E: User Service Complete Flow")
class UserServiceE2ETest {

    private static final String USER_SERVICE_URL = "http://localhost:8700";
    private static Integer testUserId;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = USER_SERVICE_URL;
        RestAssured.basePath = "/api/users";
    }

    @Test
    @Order(1)
    @DisplayName("E2E Step 1: Create new user")
    void testCreateUser() {
        String email = "e2e.test." + System.currentTimeMillis() + "@example.com";

        testUserId = given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"firstName\": \"E2E\",\n" +
                "  \"lastName\": \"TestUser\",\n" +
                "  \"email\": \"" + email + "\",\n" +
                "  \"phone\": \"1234567890\"\n" +
                "}")
        .when()
            .post()
        .then()
            .statusCode(200)
            .body("userId", notNullValue())
            .body("firstName", equalTo("E2E"))
            .body("email", equalTo(email))
        .extract()
            .path("userId");

        System.out.println("✓ User created with ID: " + testUserId);
    }

    @Test
    @Order(2)
    @DisplayName("E2E Step 2: Retrieve user by ID")
    void testGetUser() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .get("/" + testUserId)
        .then()
            .statusCode(200)
            .body("userId", equalTo(testUserId))
            .body("firstName", equalTo("E2E"))
            .body("lastName", equalTo("TestUser"));

        System.out.println("✓ User retrieved successfully");
    }

    @Test
    @Order(3)
    @DisplayName("E2E Step 3: Update user information")
    void testUpdateUser() {
        given()
            .contentType(ContentType.JSON)
            .body("{\n" +
                "  \"userId\": " + testUserId + ",\n" +
                "  \"firstName\": \"E2E Updated\",\n" +
                "  \"lastName\": \"TestUser Modified\",\n" +
                "  \"email\": \"updated@example.com\",\n" +
                "  \"phone\": \"9876543210\"\n" +
                "}")
        .when()
            .put()
        .then()
            .statusCode(200)
            .body("firstName", equalTo("E2E Updated"))
            .body("lastName", equalTo("TestUser Modified"));

        System.out.println("✓ User updated successfully");
    }

    @Test
    @Order(4)
    @DisplayName("E2E Step 4: List all users")
    void testGetAllUsers() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("collection", notNullValue())
            .body("collection.size()", greaterThan(0));

        System.out.println("✓ Retrieved all users successfully");
    }

    @Test
    @Order(5)
    @DisplayName("E2E Step 5: Delete user")
    void testDeleteUser() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .delete("/" + testUserId)
        .then()
            .statusCode(200)
            .body(equalTo("true"));

        System.out.println("✓ User deleted successfully");
    }

    @Test
    @Order(6)
    @DisplayName("E2E Step 6: Verify user was deleted")
    void testVerifyUserDeleted() {
        given()
            .contentType(ContentType.JSON)
        .when()
            .get("/" + testUserId)
        .then()
            .statusCode(anyOf(is(404), is(500))); // May return 404 or 500 depending on implementation

        System.out.println("✓ Verified user no longer exists - E2E flow complete!");
    }
}
