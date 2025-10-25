package com.selimhorri.app.resource;

import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Pruebas Unitarias para UserResource (Controller)
 * Validación de endpoints REST del servicio de usuarios
 */
@WebMvcTest(UserResource.class)
@DisplayName("User Resource Unit Tests")
class UserResourceUnitTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    private UserDto testUserDto;

    @BeforeEach
    void setUp() {
        testUserDto = new UserDto();
        testUserDto.setUserId(1);
        testUserDto.setFirstName("John");
        testUserDto.setLastName("Doe");
        testUserDto.setEmail("john.doe@test.com");
        testUserDto.setPhone("1234567890");
    }

    @Test
    @DisplayName("GET /api/users - Should return all users")
    void testGetAllUsers_ShouldReturnUserList() throws Exception {
        // Given
        List<UserDto> users = Arrays.asList(testUserDto);
        when(userService.findAll()).thenReturn(users);

        // When/Then
        mockMvc.perform(get("/api/users")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].firstName", is("John")))
                .andExpect(jsonPath("$[0].email", is("john.doe@test.com")));
    }

    @Test
    @DisplayName("GET /api/users/{id} - Should return user by ID")
    void testGetUserById_ShouldReturnUser() throws Exception {
        // Given
        when(userService.findById(1)).thenReturn(testUserDto);

        // When/Then
        mockMvc.perform(get("/api/users/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId", is(1)))
                .andExpect(jsonPath("$.firstName", is("John")))
                .andExpect(jsonPath("$.lastName", is("Doe")));
    }

    @Test
    @DisplayName("POST /api/users - Should create new user")
    void testCreateUser_ShouldReturnCreatedUser() throws Exception {
        // Given
        when(userService.save(any(UserDto.class))).thenReturn(testUserDto);

        String userJson = "{\n" +
            "    \"firstName\": \"John\",\n" +
            "    \"lastName\": \"Doe\",\n" +
            "    \"email\": \"john.doe@test.com\",\n" +
            "    \"phone\": \"1234567890\"\n" +
            "}";

        // When/Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.firstName", is("John")))
                .andExpect(jsonPath("$.email", is("john.doe@test.com")));
    }

    @Test
    @DisplayName("PUT /api/users - Should update existing user")
    void testUpdateUser_ShouldReturnUpdatedUser() throws Exception {
        // Given
        UserDto updatedUser = new UserDto();
        updatedUser.setUserId(1);
        updatedUser.setFirstName("John Updated");
        updatedUser.setLastName("Doe Updated");
        
        when(userService.update(any(UserDto.class))).thenReturn(updatedUser);

        String userJson = "{\n" +
            "    \"userId\": 1,\n" +
            "    \"firstName\": \"John Updated\",\n" +
            "    \"lastName\": \"Doe Updated\",\n" +
            "    \"email\": \"john.doe@test.com\"\n" +
            "}";

        // When/Then
        mockMvc.perform(put("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName", is("John Updated")));
    }

    @Test
    @DisplayName("DELETE /api/users/{id} - Should delete user")
    void testDeleteUser_ShouldReturnNoContent() throws Exception {
        // When/Then
        mockMvc.perform(delete("/api/users/1"))
                .andExpect(status().isNoContent());
    }
}
