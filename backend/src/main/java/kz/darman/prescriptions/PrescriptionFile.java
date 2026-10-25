package kz.darman.prescriptions;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "prescription_files")
@Getter
@Setter
@NoArgsConstructor
public class PrescriptionFile {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(nullable = false)
    private UUID prescriptionId;
    @Column(nullable = false, unique = true)
    private String storageKey;
    @Column(nullable = false)
    private String originalName;
    @Column(nullable = false)
    private String mimeType;
    @Column(nullable = false)
    private long sizeBytes;
    @Column(nullable = false)
    private String sha256;
    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();
}
