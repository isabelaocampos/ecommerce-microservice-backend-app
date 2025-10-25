package com.selimhorri.app.e2e;

import com.selimhorri.app.dto.UserDto;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Pruebas E2E para flujo de gestión de perfiles de usuario
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@DisplayName("E2E: User Profile Management Flow")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class UserProfileManagementE2ETest {

    @Autowired
    private TestRestTemplate restTemplate;

    private static UserDto testUser;

    @Test
    @Order(1)
    @DisplayName("E2E: Create New User Account")
    void step1_CreateUserAccount() {
        // Given
        UserDto newUser = new UserDto();
        newUser.setFirstName("Alice");
        newUser.setLastName("Johnson");
        newUser.setEmail("alice.johnson@ecommerce.com");
        newUser.setPhone("555-0123");

        // When
        ResponseEntity<UserDto> response = restTemplate.postForEntity(
            "/api/users",
            newUser,
            UserDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        testUser = response.getBody();
        assertThat(testUser).isNotNull();
        
        System.out.println("✓ User account created: " + testUser.getEmail());
    }

    @Test
    @Order(2)
    @DisplayName("E2E: Retrieve User Profile")
    void step2_RetrieveUserProfile() {
        // When
        ResponseEntity<UserDto> response = restTemplate.getForEntity(
            "/api/users/" + testUser.getUserId(),
            UserDto.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getEmail()).isEqualTo(testUser.getEmail());
        
        System.out.println("✓ User profile retrieved");
    }

    @Test
    @Order(3)
    @DisplayName("E2E: Update User Profile Information")
    void step3_UpdateUserProfile() {
        // Given
        testUser.setPhone("555-9999");
        testUser.setFirstName("Alice Updated");

        // When
        restTemplate.put("/api/users", testUser);

        // Then
        ResponseEntity<UserDto> response = restTemplate.getForEntity(
            "/api/users/" + testUser.getUserId(),
            UserDto.class
        );

        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getPhone()).isEqualTo("555-9999");
        assertThat(response.getBody().getFirstName()).isEqualTo("Alice Updated");
        
        System.out.println("✓ User profile updated");
    }

    @Test
    @Order(4)
    @DisplayName("E2E: List All Users")
    void step4_ListAllUsers() {
        // When
        ResponseEntity<UserDto[]> response = restTemplate.getForEntity(
            "/api/users",
            UserDto[].class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotEmpty();
        
        System.out.println("✓ User list retrieved");
    }

    @Test
    @Order(5)
    @DisplayName("E2E: Delete User Account")
    void step5_DeleteUserAccount() {
        // When
        restTemplate.delete("/api/users/" + testUser.getUserId());

        // Then
        ResponseEntity<UserDto> response = restTemplate.getForEntity(
            "/api/users/" + testUser.getUserId(),
            UserDto.class
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        
        System.out.println("✓ User account deleted");
        System.out.println("\n=== User Profile Management E2E Test Completed ===");
    }
}
