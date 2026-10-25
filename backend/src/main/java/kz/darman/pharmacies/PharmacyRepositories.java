package kz.darman.pharmacies;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public final class PharmacyRepositories {
    private PharmacyRepositories() {}

    public interface PharmacyRepository extends JpaRepository<Pharmacy, UUID> {
        List<Pharmacy> findByActiveTrueOrderByNameAsc();
    }

    public interface BranchRepository extends JpaRepository<PharmacyBranch, UUID> {
        List<PharmacyBranch> findByPharmacyIdAndActiveTrue(UUID pharmacyId);

        List<PharmacyBranch> findByActiveTrueOrderByNameAsc();

        List<PharmacyBranch> findByPharmacyId(UUID pharmacyId);
    }
}
