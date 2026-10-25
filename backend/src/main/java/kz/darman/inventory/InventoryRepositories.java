package kz.darman.inventory;

import jakarta.persistence.LockModeType;
import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

public final class InventoryRepositories {
    private InventoryRepositories() {}

    public interface OfferRepository extends JpaRepository<ProductOffer, UUID> {
        List<ProductOffer> findByIdIn(Collection<UUID> ids);

        List<ProductOffer> findByProductId(UUID productId);
    }

    public interface InventoryRepository extends JpaRepository<Inventory, UUID> {
        /** Row-level pessimistic lock, ordered by id so concurrent orders cannot deadlock. */
        @Lock(LockModeType.PESSIMISTIC_WRITE)
        @Query("select i from Inventory i where i.offerId in :ids order by i.offerId")
        List<Inventory> lockAllByIds(Collection<UUID> ids);
    }
}
