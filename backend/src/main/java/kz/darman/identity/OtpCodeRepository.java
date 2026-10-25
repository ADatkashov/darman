package kz.darman.identity;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OtpCodeRepository extends JpaRepository<OtpCode, UUID> {
    Optional<OtpCode> findFirstByPhoneOrderByCreatedAtDesc(String phone);
}
