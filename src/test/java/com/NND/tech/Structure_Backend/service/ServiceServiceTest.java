package com.NND.tech.Structure_Backend.service;

import com.NND.tech.Structure_Backend.DTO.ServiceDto;
import com.NND.tech.Structure_Backend.Exception.ResourceNotFoundException;
import com.NND.tech.Structure_Backend.mapper.ServiceMapper;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.ServiceRepository;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ServiceServiceTest {

    @Mock
    private ServiceRepository serviceRepository;

    @Mock
    private StructureRepository structureRepository;

    @Mock
    private ServiceMapper serviceMapper;

    @InjectMocks
    private ServiceServiceImpl serviceService;

    private ServiceEntity testService;
    private ServiceDto testServiceDto;
    private final Long serviceId = 1L;
    private final Long structureId = 1L;

    @BeforeEach
    void setUp() {
        // Create test structure
        Structure structure = new Structure();
        structure.setId(structureId);
        structure.setName("Test Structure");

        // Create test service
        testService = new ServiceEntity();
        testService.setId(serviceId);
        testService.setName("Test Service");
        testService.setDescription("Test Description");
        testService.setPrice(new BigDecimal("100.00"));
        testService.setDuration(60);
        testService.setStructure(structure);

        // Create test DTO
        testServiceDto = new ServiceDto();
        testServiceDto.setId(serviceId);
        testServiceDto.setName("Test Service");
        testServiceDto.setDescription("Test Description");
        testServiceDto.setPrice(new BigDecimal("100.00"));
        testServiceDto.setDuration(60);
        testServiceDto.setStructureId(structureId);
    }

    @Test
    void createService_ShouldReturnCreatedService() {
        // Arrange
        when(structureRepository.findByIdAndActiveTrue(structureId)).thenReturn(Optional.of(testService.getStructure()));
        when(serviceMapper.toEntity(any(ServiceDto.class))).thenReturn(testService);
        when(serviceRepository.existsByNameAndStructureId(anyString(), eq(structureId))).thenReturn(false);
        when(serviceRepository.save(any(ServiceEntity.class))).thenReturn(testService);
        when(serviceMapper.toDto(any(ServiceEntity.class))).thenReturn(testServiceDto);

        // Act
        ServiceDto result = serviceService.create(structureId, testServiceDto);

        // Assert
        assertNotNull(result);
        assertEquals(testServiceDto.getName(), result.getName());
        assertEquals(testServiceDto.getDescription(), result.getDescription());
        assertEquals(0, testServiceDto.getPrice().compareTo(result.getPrice()));
        assertEquals(testServiceDto.getDuration(), result.getDuration());
        verify(serviceRepository, times(1)).save(any(ServiceEntity.class));
    }

    

    @Test
    void updateService_ShouldReturnUpdatedService() {
        // Arrange
        ServiceDto updatedDto = new ServiceDto();
        updatedDto.setName("Updated Service");
        updatedDto.setDescription("Updated Description");
        updatedDto.setPrice(new BigDecimal("150.00"));
        updatedDto.setDuration(90);
        updatedDto.setStructureId(structureId);

        when(serviceRepository.findByIdAndActiveTrue(serviceId)).thenReturn(Optional.of(testService));
        when(serviceRepository.existsByNameAndStructureId(anyString(), anyLong())).thenReturn(false);
        when(serviceRepository.save(any(ServiceEntity.class))).thenReturn(testService);
        doAnswer(invocation -> {
            ServiceDto dto = invocation.getArgument(0);
            ServiceEntity entity = invocation.getArgument(1);
            entity.setName(dto.getName());
            entity.setDescription(dto.getDescription());
            entity.setPrice(dto.getPrice());
            entity.setDuration(dto.getDuration());
            return null;
        }).when(serviceMapper).updateFromDto(any(ServiceDto.class), any(ServiceEntity.class));
        when(serviceMapper.toDto(any(ServiceEntity.class))).thenAnswer(invocation -> {
            ServiceEntity s = invocation.getArgument(0);
            testServiceDto.setName(s.getName());
            testServiceDto.setDescription(s.getDescription());
            testServiceDto.setPrice(s.getPrice());
            testServiceDto.setDuration(s.getDuration());
            return testServiceDto;
        });

        // Act
        ServiceDto result = serviceService.update(serviceId, updatedDto);

        // Assert
        assertEquals(updatedDto.getName(), result.getName());
        assertEquals(updatedDto.getDescription(), result.getDescription());
        assertEquals(0, updatedDto.getPrice().compareTo(result.getPrice()));
        assertEquals(updatedDto.getDuration(), result.getDuration());
    }

    @Test
    void deleteService_ShouldDeleteService() {
        // Arrange
        when(serviceRepository.findByIdAndActiveTrue(serviceId)).thenReturn(Optional.of(testService));

        // Act
        serviceService.deleteById(serviceId);

        // Assert
        verify(serviceRepository, times(1)).save(any(ServiceEntity.class));
    }

    @Test
    void deleteService_ShouldThrowException_WhenServiceNotFound() {
        // Arrange
        when(serviceRepository.findByIdAndActiveTrue(serviceId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            serviceService.deleteById(serviceId);
        });
        verify(serviceRepository, never()).deleteById(anyLong());
    }
}
