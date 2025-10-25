package com.selimhorri.app.integration;

import com.selimhorri.app.dto.UserDto;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas de Integración para User Service
 * Validación de interacción completa del servicio con sus dependencias
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("User Service Integration Tests")
class UserServiceIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @DisplayName("Should create and retrieve user via REST API")
    void testCreateAndRetrieveUser() {
        // Given - Create user
        UserDto newUser = new UserDto();
        newUser.setFirstName("Integration");
        newUser.setLastName("Test");
        newUser.setEmail("integration@test.com");
        newUser.setPhone("9876543210");

        // When - POST new user
        ResponseEntity<UserDto> createResponse = restTemplate.postForEntity(
            "/api/users",
            newUser,
            UserDto.class
        );

        // Then - Verify creation
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(createResponse.getBody()).isNotNull();
        assertThat(createResponse.getBody().getUserId()).isNotNull();

        Integer userId = createResponse.getBody().getUserId();

        // When - GET created user
        ResponseEntity<UserDto> getResponse = restTemplate.getForEntity(
            "/api/users/" + userId,
            UserDto.class
        );

        // Then - Verify retrieval
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody()).isNotNull();
        assertThat(getResponse.getBody().getFirstName()).isEqualTo("Integration");
        assertThat(getResponse.getBody().getEmail()).isEqualTo("integration@test.com");
    }

    @Test
    @DisplayName("Should get all users from database")
    void testGetAllUsers() {
        // When
        ResponseEntity<UserDto[]> response = restTemplate.getForEntity(
            "/api/users",
            UserDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
    }

    @Test
    @DisplayName("Should update user information")
    void testUpdateUser() {
        // Given - Create user first
        UserDto newUser = new UserDto();
        newUser.setFirstName("ToUpdate");
        newUser.setLastName("User");
        newUser.setEmail("update@test.com");

        ResponseEntity<UserDto> createResponse = restTemplate.postForEntity(
            "/api/users",
            newUser,
            UserDto.class
        );

        UserDto createdUser = createResponse.getBody();
        assertThat(createdUser).isNotNull();

        // When - Update user
        createdUser.setFirstName("Updated");
        createdUser.setLastName("UserUpdated");

        restTemplate.put("/api/users", createdUser);

        // Then - Verify update
        ResponseEntity<UserDto> getResponse = restTemplate.getForEntity(
            "/api/users/" + createdUser.getUserId(),
            UserDto.class
        );

        assertThat(getResponse.getBody()).isNotNull();
        assertThat(getResponse.getBody().getFirstName()).isEqualTo("Updated");
        assertThat(getResponse.getBody().getLastName()).isEqualTo("UserUpdated");
    }

    @Test
    @DisplayName("Should delete user")
    void testDeleteUser() {
        // Given - Create user first
        UserDto newUser = new UserDto();
        newUser.setFirstName("ToDelete");
        newUser.setLastName("User");
        newUser.setEmail("delete@test.com");

        ResponseEntity<UserDto> createResponse = restTemplate.postForEntity(
            "/api/users",
            newUser,
            UserDto.class
        );

        Integer userId = createResponse.getBody().getUserId();

        // When - Delete user
        restTemplate.delete("/api/users/" + userId);

        // Then - Verify deletion
        ResponseEntity<UserDto> getResponse = restTemplate.getForEntity(
            "/api/users/" + userId,
            UserDto.class
        );

        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    @DisplayName("Should handle non-existent user gracefully")
    void testGetNonExistentUser() {
        // When
        ResponseEntity<UserDto> response = restTemplate.getForEntity(
            "/api/users/99999",
            UserDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }
}
