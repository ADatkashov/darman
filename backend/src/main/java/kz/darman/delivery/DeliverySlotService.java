package kz.darman.delivery;

import java.time.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import kz.darman.common.ApiException;
import kz.darman.pharmacies.PharmacyBranch;
import kz.darman.pharmacies.PharmacyRepositories.BranchRepository;
import org.springframework.stereotype.Service;

@Service
public class DeliverySlotService {
    public static final ZoneId ZONE = ZoneId.of("Asia/Almaty");
    private static final int[] START_HOURS = {9, 11, 13, 15, 17, 19};

    public record Slot(Instant start, Instant end) {}

    public record SlotsResponse(String timezone, boolean asapAvailable, Integer etaMinMinutes, Integer etaMaxMinutes, boolean etaIsEstimate,
                                List<Slot> slots) {}

    private final BranchRepository branches;
    private final Clock clock;

    public DeliverySlotService(BranchRepository branches) {
        this.branches = branches;
        this.clock = Clock.systemUTC();
    }

    public SlotsResponse slotsFor(UUID branchId) {
        PharmacyBranch b = branches.findById(branchId).filter(PharmacyBranch::isActive).orElseThrow(() -> ApiException.notFound("Branch"));
        if (!b.isDeliveryAvailable()) {
            return new SlotsResponse(ZONE.getId(), false, null, null, true, List.of());
        }
        return new SlotsResponse(ZONE.getId(), true, b.getDeliveryEtaMin(), b.getDeliveryEtaMax(), true, generate(b, Instant.now(clock)));
    }

    List<Slot> generate(PharmacyBranch b, Instant now) {
        int lead = (b.getDeliveryEtaMax() == null ? 60 : b.getDeliveryEtaMax()) + 30;
        Instant earliest = now.plus(Duration.ofMinutes(lead));
        LocalDate today = LocalDate.ofInstant(now, ZONE);
        List<Slot> out = new ArrayList<>();
        for (int d = 0; d < 2; d++) {
            for (int h : START_HOURS) {
                ZonedDateTime start = today.plusDays(d).atTime(h, 0).atZone(ZONE);
                if (!start.toInstant().isBefore(earliest)) out.add(new Slot(start.toInstant(), start.plusHours(2).toInstant()));
            }
        }
        return out;
    }

    /** A requested slot must be exactly one of the generated windows. */
    public Slot requireValid(UUID branchId, Instant start) {
        PharmacyBranch b = branches.findById(branchId).orElseThrow(() -> ApiException.notFound("Branch"));
        return generate(b, Instant.now(clock)).stream().filter(s -> s.start().equals(start)).findFirst()
                .orElseThrow(() -> ApiException.unprocessable("INVALID_DELIVERY_SLOT", "The selected delivery slot is not available"));
    }
}
