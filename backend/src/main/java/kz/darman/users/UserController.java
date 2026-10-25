package kz.darman.users;

import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import kz.darman.catalog.CatalogDtos.ProductCard;
import kz.darman.config.AuthUser;
import kz.darman.users.UserService.*;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users/me")
public class UserController {
    private final UserService service;

    public UserController(UserService service) {
        this.service = service;
    }

    @GetMapping
    public UserDto me(@AuthenticationPrincipal AuthUser user) {
        return service.me(user.id());
    }

    @PatchMapping
    public UserDto update(@AuthenticationPrincipal AuthUser user, @Valid @RequestBody UpdateProfileRequest req) {
        return service.update(user.id(), req);
    }

    @PostMapping("/deletion-request")
    public UserDto requestDeletion(@AuthenticationPrincipal AuthUser user) {
        return service.requestDeletion(user.id());
    }

    @DeleteMapping("/deletion-request")
    public UserDto cancelDeletion(@AuthenticationPrincipal AuthUser user) {
        return service.cancelDeletion(user.id());
    }

    @GetMapping("/addresses")
    public List<AddressDto> addresses(@AuthenticationPrincipal AuthUser user) {
        return service.addresses(user.id());
    }

    @PostMapping("/addresses")
    @ResponseStatus(HttpStatus.CREATED)
    public AddressDto createAddress(@AuthenticationPrincipal AuthUser user, @Valid @RequestBody AddressRequest req) {
        return service.createAddress(user.id(), req);
    }

    @PatchMapping("/addresses/{id}")
    public AddressDto updateAddress(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id, @Valid @RequestBody AddressRequest req) {
        return service.updateAddress(user.id(), id, req);
    }

    @DeleteMapping("/addresses/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteAddress(@AuthenticationPrincipal AuthUser user, @PathVariable UUID id) {
        service.deleteAddress(user.id(), id);
    }

    @GetMapping("/favorites")
    public List<ProductCard> favorites(@AuthenticationPrincipal AuthUser user) {
        return service.favorites(user.id());
    }

    @PutMapping("/favorites/{productId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addFavorite(@AuthenticationPrincipal AuthUser user, @PathVariable UUID productId) {
        service.addFavorite(user.id(), productId);
    }

    @DeleteMapping("/favorites/{productId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeFavorite(@AuthenticationPrincipal AuthUser user, @PathVariable UUID productId) {
        service.removeFavorite(user.id(), productId);
    }
}
