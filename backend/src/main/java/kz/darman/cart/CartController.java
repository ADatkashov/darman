package kz.darman.cart;

import jakarta.validation.Valid;
import java.util.UUID;
import kz.darman.cart.CartDtos.*;
import kz.darman.config.AuthUser;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/cart")
public class CartController {
    private final CartService service;

    public CartController(CartService service) {
        this.service = service;
    }

    @GetMapping
    public CartDto get(@AuthenticationPrincipal AuthUser user) {
        return service.get(user.id());
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    public CartDto add(@AuthenticationPrincipal AuthUser user, @Valid @RequestBody AddItemRequest req) {
        return service.add(user.id(), req);
    }

    @PatchMapping("/items/{id}")
    public CartDto update(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody UpdateItemRequest req) {
        return service.update(user.id(), id, req);
    }

    @DeleteMapping("/items/{id}")
    public CartDto remove(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.remove(user.id(), id);
    }

    @DeleteMapping
    public CartDto clear(@AuthenticationPrincipal AuthUser user) {
        return service.clear(user.id());
    }

    /** Public: revalidates a device-held cart against current prices, stock and branch rules. Persists nothing. */
    @PostMapping("/validate")
    public CartDto validate(@Valid @RequestBody ValidateRequest req) {
        return service.validate(req.items());
    }
}
