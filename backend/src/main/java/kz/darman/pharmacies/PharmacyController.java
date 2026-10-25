package kz.darman.pharmacies;

import java.util.List;
import java.util.UUID;
import kz.darman.common.PageResponse;
import kz.darman.pharmacies.PharmacyService.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/pharmacies")
public class PharmacyController {
    private final PharmacyService service;

    public PharmacyController(PharmacyService service) {
        this.service = service;
    }

    /** Branch list; pass lat/lon to sort by distance. */
    @GetMapping
    public List<BranchDto> list(@RequestParam(required = false) String city, @RequestParam(required = false) Double lat,
                                @RequestParam(required = false) Double lon, @RequestParam(required = false) Boolean deliveryOnly) {
        return service.nearby(city, lat, lon, deliveryOnly);
    }

    @GetMapping("/{id}")
    public PharmacyDto get(@PathVariable UUID id) {
        return service.get(id);
    }

    @GetMapping("/{id}/products")
    public PageResponse<PharmacyProductDto> products(@PathVariable UUID id, @RequestParam(defaultValue = "0") int page,
                                                     @RequestParam(defaultValue = "20") int size) {
        return service.products(id, Math.max(0, page), Math.min(Math.max(1, size), 50));
    }
}
