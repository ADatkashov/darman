package kz.darman.delivery;

import java.util.UUID;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/delivery")
public class DeliveryController {
    private final DeliverySlotService slots;

    public DeliveryController(DeliverySlotService slots) {
        this.slots = slots;
    }

    @GetMapping("/slots")
    public DeliverySlotService.SlotsResponse slots(@RequestParam UUID branchId) {
        return slots.slotsFor(branchId);
    }
}
