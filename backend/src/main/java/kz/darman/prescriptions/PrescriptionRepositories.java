package kz.darman.prescriptions;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public final class PrescriptionRepositories {
    private PrescriptionRepositories() {}

    public interface PrescriptionRepository extends JpaRepository<Prescription, UUID> {
        List<Prescription> findByUserIdOrderByCreatedAtDesc(UUID userId);

        Page<Prescription> findByStatusInOrderBySubmittedAtAsc(List<PrescriptionStatus> statuses, Pageable pageable);

        Page<Prescription> findAllByOrderByCreatedAtDesc(Pageable pageable);

        @Query("select p from Prescription p where p.status = 'APPROVED' and p.expiresAt < :now")
        List<Prescription> findExpired(Instant now);

        List<Prescription> findByStatusAndSubmittedAtBefore(PrescriptionStatus status, Instant before);
    }

    public interface FileRepository extends JpaRepository<PrescriptionFile, UUID> {
        List<PrescriptionFile> findByPrescriptionIdOrderByCreatedAtAsc(UUID prescriptionId);

        long countByPrescriptionId(UUID prescriptionId);
    }

    public interface EventRepository extends JpaRepository<PrescriptionReviewEvent, UUID> {
        List<PrescriptionReviewEvent> findByPrescriptionIdOrderByCreatedAtAsc(UUID prescriptionId);
    }
}
