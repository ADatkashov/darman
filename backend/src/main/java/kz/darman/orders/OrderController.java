package kz.darman.orders;

import jakarta.validation.Valid;
import java.util.UUID;
import kz.darman.cart.CartDtos.CartDto;
import kz.darman.common.PageResponse;
import kz.darman.config.AuthUser;
import kz.darman.orders.OrderDtos.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {
    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    /** 201 for a new order, 200 when an identical Idempotency-Key replays an existing one. */
    @PostMapping
    public ResponseEntity<OrderDto> place(@AuthenticationPrincipal AuthUser user, @Valid @RequestBody PlaceOrderRequest req,
                                          @RequestHeader(value = "Idempotency-Key", required = false) String idempotencyKey) {
        try {
            OrderService.Placement p = service.place(user.id(), req, idempotencyKey);
            return ResponseEntity.status(p.replay() ? HttpStatus.OK : HttpStatus.CREATED).body(p.order());
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            // Lost an insert race against an identical request: the whole transaction (including stock) rolled back.
            return service.findByIdempotencyKey(user.id(), idempotencyKey).map(o -> ResponseEntity.ok(o)).orElseThrow(() -> e);
        }
    }

    @GetMapping
    public PageResponse<OrderSummary> list(@AuthenticationPrincipal AuthUser user, @RequestParam(defaultValue = "all") String scope,
                                           @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return service.list(user.id(), scope, Math.max(0, page), Math.min(Math.max(1, size), 50));
    }

    @GetMapping("/{id}")
    public OrderDto get(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.get(user.id(), id);
    }

    @PostMapping("/{id}/cancel")
    public OrderDto cancel(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody(required = false) CancelRequest req) {
        return service.cancel(user.id(), id, req == null ? null : req.reason());
    }

    @GetMapping("/{id}/receipt")
    public Receipt receipt(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.receipt(user.id(), id);
    }

    /** Re-validates availability, prices, prescription requirement and branch eligibility. Persists nothing. */
    @PostMapping("/{id}/reorder")
    public CartDto reorder(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        return service.reorder(user.id(), id);
    }
}
