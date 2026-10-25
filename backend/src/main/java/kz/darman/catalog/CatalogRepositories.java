package kz.darman.catalog;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public final class CatalogRepositories {
    private CatalogRepositories() {}

    public interface ProductRepository extends JpaRepository<Product, UUID> {
        Optional<Product> findBySlug(String slug);
    }

    public interface CategoryRepository extends JpaRepository<Category, UUID> {
        List<Category> findByActiveTrueOrderBySortOrderAsc();

        Optional<Category> findBySlug(String slug);
    }

    public interface ManufacturerRepository extends JpaRepository<Manufacturer, UUID> {
        Optional<Manufacturer> findByName(String name);
    }

    public interface ProductInfoRepository extends JpaRepository<ProductInfo, UUID> {
        List<ProductInfo> findByProductId(UUID productId);

        Optional<ProductInfo> findByProductIdAndSectionAndLocale(UUID productId, String section, String locale);
    }

    public interface ProductImageRepository extends JpaRepository<ProductImage, UUID> {
        List<ProductImage> findByProductIdOrderBySortOrderAsc(UUID productId);
    }
}
