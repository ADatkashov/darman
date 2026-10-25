package kz.darman.orders;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import kz.darman.delivery.Delivery;
import kz.darman.payments.PaymentAttempt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public final class OrderRepositories {
    private OrderRepositories() {}

    public interface OrderRepository extends JpaRepository<Order, UUID> {
        Optional<Order> findByIdAndUserId(UUID id, UUID userId);

        Optional<Order> findByUserIdAndIdempotencyKey(UUID userId, String key);

        Page<Order> findByUserIdAndStatusInOrderByCreatedAtDesc(UUID userId, Collection<OrderStatus> statuses, Pageable pageable);

        @Query("""
                select o from Order o where o.status in :statuses
                  and (:q = '' or o.number like concat('%', :q, '%') or o.contactPhone like concat('%', :q, '%'))
                order by o.createdAt desc""")
        Page<Order> search(Collection<OrderStatus> statuses, String q, Pageable pageable);

        List<Order> findByStatusInAndUpdatedAtBefore(Collection<OrderStatus> statuses, java.time.Instant before);

        boolean existsByNumber(String number);
    }

    public interface OrderItemRepository extends JpaRepository<OrderItem, UUID> {
        List<OrderItem> findByOrderId(UUID orderId);
    }

    public interface HistoryRepository extends JpaRepository<OrderStatusHistory, UUID> {
        List<OrderStatusHistory> findByOrderIdOrderByCreatedAtAsc(UUID orderId);
    }

    public interface DeliveryRepository extends JpaRepository<Delivery, UUID> {
        Optional<Delivery> findByOrderId(UUID orderId);
    }

    public interface PaymentAttemptRepository extends JpaRepository<PaymentAttempt, UUID> {
        Optional<PaymentAttempt> findByProviderAndProviderRef(String provider, String providerRef);

        List<PaymentAttempt> findByOrderIdOrderByCreatedAtDesc(UUID orderId);
    }
}
