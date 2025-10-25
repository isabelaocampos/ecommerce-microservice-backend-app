package com.selimhorri.app.service;

import com.selimhorri.app.domain.User;
import com.selimhorri.app.dto.UserDto;
import com.selimhorri.app.repository.UserRepository;
import com.selimhorri.app.service.impl.UserServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para UserService
 * Validación de lógica de negocio del servicio de usuarios
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("User Service Unit Tests")
class UserServiceUnitTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    private User testUser;
    private UserDto testUserDto;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId(1);
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
        testUser.setEmail("john.doe@test.com");
        testUser.setPhone("1234567890");

        testUserDto = new UserDto();
        testUserDto.setUserId(1);
        testUserDto.setFirstName("John");
        testUserDto.setLastName("Doe");
        testUserDto.setEmail("john.doe@test.com");
        testUserDto.setPhone("1234567890");
    }

    @Test
    @DisplayName("Should find all users successfully")
    void testFindAll_ShouldReturnListOfUsers() {
        // Given
        List<User> users = Arrays.asList(testUser, createUser(2, "Jane", "Smith"));
        when(userRepository.findAll()).thenReturn(users);

        // When
        List<UserDto> result = userService.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(2);
        verify(userRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find user by ID successfully")
    void testFindById_WhenUserExists_ShouldReturnUser() {
        // Given
        when(userRepository.findById(1)).thenReturn(Optional.of(testUser));

        // When
        UserDto result = userService.findById(1);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getUserId()).isEqualTo(1);
        assertThat(result.getFirstName()).isEqualTo("John");
        assertThat(result.getEmail()).isEqualTo("john.doe@test.com");
        verify(userRepository, times(1)).findById(1);
    }

    @Test
    @DisplayName("Should throw exception when user not found by ID")
    void testFindById_WhenUserDoesNotExist_ShouldThrowException() {
        // Given
        when(userRepository.findById(anyInt())).thenReturn(Optional.empty());

        // When/Then
        assertThatThrownBy(() -> userService.findById(999))
            .isInstanceOf(RuntimeException.class);
        verify(userRepository, times(1)).findById(999);
    }

    @Test
    @DisplayName("Should save user successfully")
    void testSave_ShouldCreateNewUser() {
        // Given
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        UserDto result = userService.save(testUserDto);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getFirstName()).isEqualTo("John");
        assertThat(result.getEmail()).isEqualTo("john.doe@test.com");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Should update user successfully")
    void testUpdate_WhenUserExists_ShouldUpdateUser() {
        // Given
        User updatedUser = new User();
        updatedUser.setUserId(1);
        updatedUser.setFirstName("John Updated");
        updatedUser.setLastName("Doe Updated");
        updatedUser.setEmail("john.updated@test.com");
        
        when(userRepository.save(any(User.class))).thenReturn(updatedUser);

        UserDto updateDto = new UserDto();
        updateDto.setUserId(1);
        updateDto.setFirstName("John Updated");
        updateDto.setLastName("Doe Updated");
        updateDto.setEmail("john.updated@test.com");

        // When
        UserDto result = userService.update(updateDto);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getFirstName()).isEqualTo("John Updated");
        assertThat(result.getEmail()).isEqualTo("john.updated@test.com");
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("Should delete user successfully")
    void testDeleteById_ShouldRemoveUser() {
        // Given
        doNothing().when(userRepository).deleteById(1);

        // When
        userService.deleteById(1);

        // Then
        verify(userRepository, times(1)).deleteById(1);
    }

    // Helper method
    private User createUser(Integer id, String firstName, String lastName) {
        User user = new User();
        user.setUserId(id);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(firstName.toLowerCase() + "@test.com");
        return user;
    }
}
