package com.selimhorri.app.service;

import com.selimhorri.app.domain.Order;
import com.selimhorri.app.domain.Cart;
import com.selimhorri.app.dto.OrderDto;
import com.selimhorri.app.dto.CartDto;
import com.selimhorri.app.repository.OrderRepository;
import com.selimhorri.app.service.impl.OrderServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Pruebas Unitarias para OrderService
 * Validación de lógica de negocio del servicio de órdenes
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("Order Service Unit Tests")
class OrderServiceUnitTest {

    @Mock
    private OrderRepository orderRepository;

    @InjectMocks
    private OrderServiceImpl orderService;

    private Order testOrder;
    private Cart testCart;

    @BeforeEach
    void setUp() {
        // Setup Cart
        testCart = new Cart();
        testCart.setCartId(1);
        
        // Setup Order with Cart
        testOrder = new Order();
        testOrder.setOrderId(1);
        testOrder.setOrderDate(LocalDateTime.now());
        testOrder.setOrderDesc("Test Order");
        testOrder.setCart(testCart);
    }

    @Test
    @DisplayName("Should find all orders successfully")
    void testFindAll_ShouldReturnListOfOrders() {
        // Given
        when(orderRepository.findAll()).thenReturn(Arrays.asList(testOrder));

        // When
        List<OrderDto> result = orderService.findAll();

        // Then
        assertThat(result).isNotNull();
        assertThat(result).hasSize(1);
        verify(orderRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Should find order by ID successfully")
    void testFindById_WhenOrderExists_ShouldReturnOrder() {
        // Given
        when(orderRepository.findById(1)).thenReturn(Optional.of(testOrder));

        // When
        OrderDto result = orderService.findById(1);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getOrderId()).isEqualTo(1);
        assertThat(result.getOrderDesc()).isEqualTo("Test Order");
    }

    @Test
    @DisplayName("Should save order successfully")
    void testSave_ShouldCreateNewOrder() {
        // Given
        when(orderRepository.save(any(Order.class))).thenReturn(testOrder);

        OrderDto orderDto = new OrderDto();
        orderDto.setOrderDesc("Test Order");
        
        // Add CartDto to avoid NullPointerException
        CartDto cartDto = new CartDto();
        cartDto.setCartId(1);
        orderDto.setCartDto(cartDto);

        // When
        OrderDto result = orderService.save(orderDto);

        // Then
        assertThat(result).isNotNull();
        verify(orderRepository, times(1)).save(any(Order.class));
    }
}
