package com.NND.tech.Structure_Backend.service;

import com.NND.tech.Structure_Backend.DTO.UserDto;
import com.NND.tech.Structure_Backend.Exception.ResourceNotFoundException;
import com.NND.tech.Structure_Backend.mapper.UserMapper;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.model.entity.User;
import com.NND.tech.Structure_Backend.model.entity.RoleType;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private StructureRepository structureRepository;

    @Mock
    private UserMapper userMapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserServiceImpl userService;

    private User testUser;
    private UserDto testUserDto;
    private final Long userId = 1L;
    private final Long structureId = 1L;

    @BeforeEach
    void setUp() {
        // Create test structure
        Structure structure = new Structure();
        structure.setId(structureId);
        structure.setName("Test Structure");

        // Create test user
        testUser = new User();
        testUser.setId(userId);
        testUser.setFirstName("John");
        testUser.setLastName("Doe");
        testUser.setEmail("john.doe@example.com");
        testUser.setRole(RoleType.ADMIN);
        testUser.setStructure(structure);

        // Create test DTO
        testUserDto = new UserDto();
        testUserDto.setId(userId);
        testUserDto.setFirstName("John");
        testUserDto.setLastName("Doe");
        testUserDto.setEmail("john.doe@example.com");
        testUserDto.setRole(RoleType.ADMIN);
        testUserDto.setStructureId(structureId);
        testUserDto.setPassword("password123");
    }

    @Test
    void createUser_ShouldReturnCreatedUser() {
        // Arrange
        when(userMapper.toEntity(any(UserDto.class))).thenReturn(testUser);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(userMapper.toDto(any(User.class))).thenReturn(testUserDto);

        // Act
        UserDto result = userService.create(testUserDto);

        // Assert
        assertNotNull(result);
        assertEquals(testUserDto.getEmail(), result.getEmail());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void getUserById_ShouldReturnUser_WhenFound() {
        // Arrange
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(userMapper.toDto(any(User.class))).thenReturn(testUserDto);

        // Act
        UserDto result = userService.findById(userId);

        // Assert
        assertNotNull(result);
        assertEquals(testUserDto.getId(), result.getId());
        verify(userRepository, times(1)).findById(userId);
    }

    @Test
    void getUserById_ShouldThrowException_WhenNotFound() {
        // Arrange
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            userService.findById(userId);
        });
        verify(userRepository, times(1)).findById(userId);
    }

    @Test
    void getUserByEmail_ShouldReturnUser_WhenFound() {
        // Arrange
        String email = "john.doe@example.com";
        when(userRepository.findByEmail(email)).thenReturn(Optional.of(testUser));
        when(userMapper.toDto(any(User.class))).thenReturn(testUserDto);

        // Act
        UserDto result = userService.findByEmail(email);

        // Assert
        assertNotNull(result);
        assertEquals(email, result.getEmail());
        verify(userRepository, times(1)).findByEmail(email);
    }

    @Test
    void getAllUsers_ShouldReturnAllUsers() {
        // Arrange
        User user2 = new User();
        user2.setId(2L);
        user2.setEmail("jane.doe@example.com");
        
        UserDto userDto2 = new UserDto();
        userDto2.setId(2L);
        userDto2.setEmail("jane.doe@example.com");
        
        List<User> users = Arrays.asList(testUser, user2);
        when(userRepository.findAll()).thenReturn(users);
        when(userMapper.toDto(testUser)).thenReturn(testUserDto);
        when(userMapper.toDto(user2)).thenReturn(userDto2);

        // Act
        List<UserDto> result = userService.findAll();

        // Assert
        assertEquals(2, result.size());
        verify(userRepository, times(1)).findAll();
    }

    // Removed test for non-existent service method getUsersByStructure

    @Test
    void updateUser_ShouldReturnUpdatedUser() {
        // Arrange
        UserDto updatedDto = new UserDto();
        updatedDto.setFirstName("John Updated");
        updatedDto.setLastName("Doe Updated");
        updatedDto.setEmail("john.updated@example.com");
        updatedDto.setRole(RoleType.ADMIN);
        updatedDto.setStructureId(structureId);

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(userMapper.toDto(any(User.class))).thenAnswer(invocation -> {
            User u = invocation.getArgument(0);
            testUserDto.setFirstName(u.getFirstName());
            testUserDto.setLastName(u.getLastName());
            testUserDto.setEmail(u.getEmail());
            return testUserDto;
        });

        // Act
        UserDto result = userService.update(userId, updatedDto);

        // Assert
        assertNotNull(result);
        assertEquals(updatedDto.getFirstName(), result.getFirstName());
        assertEquals(updatedDto.getLastName(), result.getLastName());
        assertEquals(updatedDto.getEmail(), result.getEmail());
        verify(userRepository, times(1)).findById(userId);
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void deleteUser_ShouldDeleteUser() {
        // Arrange
        when(userRepository.existsById(userId)).thenReturn(true);
        doNothing().when(userRepository).deleteById(userId);

        // Act
        userService.delete(userId);

        // Assert
        verify(userRepository, times(1)).deleteById(userId);
    }

    @Test
    void deleteUser_ShouldThrowException_WhenUserNotFound() {
        // Arrange
        when(userRepository.existsById(userId)).thenReturn(false);

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            userService.delete(userId);
        });
        verify(userRepository, never()).deleteById(anyLong());
    }

    // Removed test for non-existent service method updatePassword
}
