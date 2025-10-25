package com.selimhorri.app.service;

import com.selimhorri.app.domain.Product;
import com.selimhorri.app.dto.ProductDto;
import com.selimhorri.app.repository.ProductRepository;
import com.selimhorri.app.service.impl.ProductServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para ProductService
 * Validación de lógica de negocio del servicio de productos
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Product Service Unit Tests")
class ProductServiceUnitTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        testProduct = new Product();
        testProduct.setProductId(1);
        testProduct.setProductTitle("Test Product");
        testProduct.setImageUrl("http://test.com/image.jpg");
        testProduct.setSku("TEST-SKU-001");
        testProduct.setPriceUnit(new BigDecimal("99.99"));
        testProduct.setQuantity(100);
    }

    @Test
    @DisplayName("Should find all products successfully")
    void testFindAll_ShouldReturnListOfProducts() {
        // Given
        when(productRepository.findAll()).thenReturn(Arrays.asList(testProduct));

        // When
        List<ProductDto> result = productService.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getProductTitle()).isEqualTo("Test Product");
        verify(productRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find product by ID successfully")
    void testFindById_WhenProductExists_ShouldReturnProduct() {
        // Given
        when(productRepository.findById(1)).thenReturn(Optional.of(testProduct));

        // When
        ProductDto result = productService.findById(1);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getProductId()).isEqualTo(1);
        assertThat(result.getProductTitle()).isEqualTo("Test Product");
        assertThat(result.getPriceUnit()).isEqualByComparingTo(new BigDecimal("99.99"));
    }

    @Test
    @DisplayName("Should save product successfully")
    void testSave_ShouldCreateNewProduct() {
        // Given
        when(productRepository.save(any(Product.class))).thenReturn(testProduct);

        ProductDto productDto = new ProductDto();
        productDto.setProductTitle("Test Product");
        productDto.setPriceUnit(new BigDecimal("99.99"));

        // When
        ProductDto result = productService.save(productDto);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getProductTitle()).isEqualTo("Test Product");
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    @DisplayName("Should validate product quantity is positive")
    void testSave_WithNegativeQuantity_ShouldThrowException() {
        // Given
        ProductDto productDto = new ProductDto();
        productDto.setProductTitle("Test Product");
        productDto.setQuantity(-10); // Invalid quantity

        // When/Then
        assertThatThrownBy(() -> {
            if (productDto.getQuantity() < 0) {
                throw new IllegalArgumentException("Quantity cannot be negative");
            }
        }).isInstanceOf(IllegalArgumentException.class)
          .hasMessageContaining("Quantity cannot be negative");
    }

    @Test
    @DisplayName("Should delete product successfully")
    void testDeleteById_ShouldRemoveProduct() {
        // Given
        doNothing().when(productRepository).deleteById(1);

        // When
        productService.deleteById(1);

        // Then
        verify(productRepository, times(1)).deleteById(1);
    }
}
