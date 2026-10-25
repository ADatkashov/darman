package kz.darman.promotions;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;
import kz.darman.common.Lang;
import kz.darman.promotions.PromotionService.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/promotions")
public class PromotionController {
    public record CheckRequest(@NotBlank String code, @NotNull BigDecimal subtotal) {}

    private final PromotionService service;

    public PromotionController(PromotionService service) {
        this.service = service;
    }

    @GetMapping
    public List<BannerDto> banners(@RequestParam(required = false) String lang) {
        return service.banners(Lang.resolve(lang));
    }

    @PostMapping("/validate")
    public PromoCheck validate(@Valid @RequestBody CheckRequest req) {
        return service.check(req.code(), req.subtotal());
    }
}
