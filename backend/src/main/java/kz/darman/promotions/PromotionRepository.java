package kz.darman.promotions;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PromotionRepository extends JpaRepository<Promotion, UUID> {
    List<Promotion> findByKindAndActiveTrueOrderBySortOrderAsc(String kind);

    Optional<Promotion> findByCodeIgnoreCase(String code);
}
