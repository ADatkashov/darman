package kz.darman.demo;

import java.time.Duration;
import java.time.Instant;
import java.util.EnumSet;
import java.util.List;
import java.util.UUID;
import kz.darman.config.AppProperties;
import kz.darman.orders.Order;
import kz.darman.orders.OrderService;
import kz.darman.orders.OrderStatus;
import kz.darman.prescriptions.Prescription;
import kz.darman.prescriptions.PrescriptionRepositories.PrescriptionRepository;
import kz.darman.prescriptions.PrescriptionService;
import kz.darman.prescriptions.PrescriptionStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * DEMO ONLY. Advances orders through the delivery timeline on a timer so the tracking screen can be demonstrated.
 * There is no real courier or GPS integration; the courier shown is fictional and flagged as demo.
 */
@Component
@ConditionalOnProperty(name = "darman.demo.auto-progress", havingValue = "true")
public class DemoProgressionJob {
    private static final Logger log = LoggerFactory.getLogger(DemoProgressionJob.class);
    private final OrderService orders;
    private final PrescriptionRepository prescriptions;
    private final PrescriptionService prescriptionService;
    private final AppProperties props;

    public DemoProgressionJob(OrderService orders, PrescriptionRepository prescriptions, PrescriptionService prescriptionService, AppProperties props) {
        this.orders = orders;
        this.prescriptions = prescriptions;
        this.prescriptionService = prescriptionService;
        this.props = props;
    }

    @Scheduled(fixedDelayString = "${darman.demo.tick-millis:5000}", initialDelayString = "PT20S")
    public void tick() {
        Instant cutoff = Instant.now().minus(Duration.ofSeconds(props.demo().stepSeconds()));
        List<Order> due = orders.findStale(EnumSet.of(OrderStatus.PLACED, OrderStatus.CONFIRMED, OrderStatus.PREPARING,
                OrderStatus.READY_FOR_PICKUP, OrderStatus.IN_TRANSIT), cutoff);
        for (Order o : due) {
            try {
                OrderStatus next = o.getStatus().next(o.getFulfillment());
                if (next == null) continue;
                orders.moveTo(o.getId(), next, "DEMO: simulated progression", null);
                if (next == OrderStatus.IN_TRANSIT) orders.assignDemoCourier(o.getId());
            } catch (RuntimeException e) {
                log.debug("Demo progression skipped for {}: {}", o.getNumber(), e.getMessage());
            }
        }
        if (props.demo().autoReviewPrescriptions()) {
            for (Prescription p : prescriptions.findByStatusAndSubmittedAtBefore(PrescriptionStatus.SUBMITTED, cutoff)) {
                prescriptionService.demoAutoReview(p.getId(), null, false);
            }
            for (Prescription p : prescriptions.findByStatusAndSubmittedAtBefore(PrescriptionStatus.UNDER_REVIEW, cutoff.minusSeconds(props.demo().stepSeconds()))) {
                if (p.getReviewedBy() == null) prescriptionService.demoAutoReview(p.getId(), null, true);
            }
        }
    }

}
