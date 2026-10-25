package kz.darman.users;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import kz.darman.audit.AuditService;
import kz.darman.catalog.CatalogDtos.ProductCard;
import kz.darman.catalog.CatalogService;
import kz.darman.common.ApiException;
import kz.darman.identity.RefreshTokenRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {
    public record UpdateProfileRequest(@Size(max = 160) String fullName, @Email @Size(max = 160) String email,
                                       @Pattern(regexp = "ru|kk|en") String locale, Boolean notifyOrders,
                                       Boolean notifyPromotions, Boolean notifyPrescriptions) {}

    public record AddressRequest(@Size(max = 60) String label, @NotBlank @Size(max = 80) String city,
                                 @NotBlank @Size(max = 160) String street, @NotBlank @Size(max = 20) String house,
                                 @Size(max = 20) String apartment, @Size(max = 20) String entrance, @Size(max = 20) String floor,
                                 @Size(max = 255) String comment, Double latitude, Double longitude, Boolean defaultAddress) {}

    public record AddressDto(UUID id, String label, String city, String street, String house, String apartment, String entrance,
                             String floor, String comment, Double latitude, Double longitude, boolean defaultAddress, String formatted) {
        static AddressDto of(Address a) {
            return new AddressDto(a.getId(), a.getLabel(), a.getCity(), a.getStreet(), a.getHouse(), a.getApartment(), a.getEntrance(),
                    a.getFloor(), a.getComment(), a.getLatitude(), a.getLongitude(), a.isDefaultAddress(), a.oneLine());
        }
    }

    private final UserRepository users;
    private final AddressRepository addresses;
    private final FavoriteRepository favorites;
    private final RefreshTokenRepository refreshTokens;
    private final CatalogService catalog;
    private final AuditService audit;

    public UserService(UserRepository users, AddressRepository addresses, FavoriteRepository favorites,
                       RefreshTokenRepository refreshTokens, CatalogService catalog, AuditService audit) {
        this.users = users;
        this.addresses = addresses;
        this.favorites = favorites;
        this.refreshTokens = refreshTokens;
        this.catalog = catalog;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public UserDto me(UUID id) {
        return UserDto.of(load(id));
    }

    @Transactional
    public UserDto update(UUID id, UpdateProfileRequest r) {
        User u = load(id);
        if (r.fullName() != null) u.setFullName(r.fullName().isBlank() ? null : r.fullName().trim());
        if (r.email() != null) u.setEmail(r.email().isBlank() ? null : r.email().trim());
        if (r.locale() != null) u.setLocale(r.locale());
        if (r.notifyOrders() != null) u.setNotifyOrders(r.notifyOrders());
        if (r.notifyPromotions() != null) u.setNotifyPromotions(r.notifyPromotions());
        if (r.notifyPrescriptions() != null) u.setNotifyPrescriptions(r.notifyPrescriptions());
        return UserDto.of(users.save(u));
    }

    @Transactional
    public UserDto requestDeletion(UUID id) {
        User u = load(id);
        u.setDeletionRequestedAt(Instant.now());
        users.save(u);
        audit.record("ACCOUNT_DELETION_REQUESTED", "User", id, null);
        return UserDto.of(u);
    }

    @Transactional
    public UserDto cancelDeletion(UUID id) {
        User u = load(id);
        u.setDeletionRequestedAt(null);
        users.save(u);
        audit.record("ACCOUNT_DELETION_CANCELLED", "User", id, null);
        return UserDto.of(u);
    }

    @Transactional(readOnly = true)
    public List<AddressDto> addresses(UUID userId) {
        return addresses.findByUserIdOrderByDefaultAddressDescCreatedAtDesc(userId).stream().map(AddressDto::of).toList();
    }

    @Transactional
    public AddressDto createAddress(UUID userId, AddressRequest r) {
        if (addresses.countByUserId(userId) >= 20) {
            throw ApiException.unprocessable("TOO_MANY_ADDRESSES", "Address limit reached");
        }
        Address a = new Address();
        a.setUserId(userId);
        apply(a, r);
        boolean first = addresses.countByUserId(userId) == 0;
        a.setDefaultAddress(first || Boolean.TRUE.equals(r.defaultAddress()));
        if (a.isDefaultAddress()) clearDefaults(userId);
        return AddressDto.of(addresses.save(a));
    }

    @Transactional
    public AddressDto updateAddress(UUID userId, UUID id, AddressRequest r) {
        Address a = addresses.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Address"));
        apply(a, r);
        if (Boolean.TRUE.equals(r.defaultAddress())) {
            clearDefaults(userId);
            a.setDefaultAddress(true);
        }
        return AddressDto.of(addresses.save(a));
    }

    @Transactional
    public void deleteAddress(UUID userId, UUID id) {
        Address a = addresses.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Address"));
        boolean wasDefault = a.isDefaultAddress();
        addresses.delete(a);
        addresses.flush();
        if (wasDefault) {
            addresses.findByUserIdOrderByDefaultAddressDescCreatedAtDesc(userId).stream().findFirst().ifPresent(n -> n.setDefaultAddress(true));
        }
    }

    @Transactional(readOnly = true)
    public Address requireAddress(UUID userId, UUID id) {
        return addresses.findByIdAndUserId(id, userId).orElseThrow(() -> ApiException.notFound("Address"));
    }

    @Transactional(readOnly = true)
    public List<ProductCard> favorites(UUID userId) {
        List<UUID> ids = favorites.findByUserIdOrderByCreatedAtDesc(userId).stream().map(Favorite::getProductId).toList();
        return catalog.cardsInOrder(ids);
    }

    @Transactional
    public void addFavorite(UUID userId, UUID productId) {
        catalog.offersFor(productId, "price_asc"); // 404 when the product does not exist
        if (!favorites.existsByUserIdAndProductId(userId, productId)) favorites.save(new Favorite(userId, productId));
    }

    @Transactional
    public void removeFavorite(UUID userId, UUID productId) {
        favorites.deleteByUserIdAndProductId(userId, productId);
    }

    private void clearDefaults(UUID userId) {
        addresses.findByUserIdOrderByDefaultAddressDescCreatedAtDesc(userId).forEach(x -> x.setDefaultAddress(false));
        addresses.flush();
    }

    private void apply(Address a, AddressRequest r) {
        a.setLabel(blankToNull(r.label()));
        a.setCity(r.city().trim());
        a.setStreet(r.street().trim());
        a.setHouse(r.house().trim());
        a.setApartment(blankToNull(r.apartment()));
        a.setEntrance(blankToNull(r.entrance()));
        a.setFloor(blankToNull(r.floor()));
        a.setComment(blankToNull(r.comment()));
        a.setLatitude(r.latitude());
        a.setLongitude(r.longitude());
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private User load(UUID id) {
        return users.findById(id).orElseThrow(() -> ApiException.notFound("User"));
    }
}
