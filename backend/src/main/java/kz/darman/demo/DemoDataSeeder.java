package kz.darman.demo;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import kz.darman.cart.CartDtos.LineInput;
import kz.darman.config.AppProperties;
import kz.darman.orders.Fulfillment;
import kz.darman.orders.Order;
import kz.darman.orders.OrderDtos.PlaceOrderRequest;
import kz.darman.orders.OrderService;
import kz.darman.orders.OrderStatus;
import kz.darman.orders.PaymentMethod;
import kz.darman.users.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * DEMO ONLY (darman.demo.seed-accounts=true). Creates fictional staff and customer accounts plus a demo order history.
 * The shared demo password comes from DARMAN_DEMO_PASSWORD; when unset a random one is generated and printed once to the log.
 */
@Component
@ConditionalOnProperty(name = "darman.demo.seed-accounts", havingValue = "true")
public class DemoDataSeeder implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(DemoDataSeeder.class);
    public static final String CUSTOMER_PHONE = "+77000000010";

    private record Account(String phone, String name, String role) {}

    private static final List<Account> ACCOUNTS = List.of(
            new Account("+77000000001", "Демо Администратор", "ADMIN"),
            new Account("+77000000002", "Демо Фармацевт", "PHARMACIST"),
            new Account("+77000000003", "Демо Оператор", "OPERATOR"),
            new Account("+77000000004", "Демо Контент-менеджер", "CATALOG_MANAGER"),
            new Account(CUSTOMER_PHONE, "Анна Иванова (демо)", "CUSTOMER"));

    private final UserRepository users;
    private final AddressRepository addresses;
    private final PasswordEncoder encoder;
    private final OrderService orders;
    private final JdbcTemplate jdbc;
    private final AppProperties props;

    public DemoDataSeeder(UserRepository users, AddressRepository addresses, PasswordEncoder encoder, OrderService orders, JdbcTemplate jdbc,
                          AppProperties props) {
        this.users = users;
        this.addresses = addresses;
        this.encoder = encoder;
        this.orders = orders;
        this.jdbc = jdbc;
        this.props = props;
    }

    @Override
    public void run(ApplicationArguments args) {
        String password = props.demo().password();
        boolean generated = password == null || password.isBlank();
        if (generated) password = randomPassword();
        boolean createdAny = false;
        for (Account a : ACCOUNTS) {
            if (users.findByPhone(a.phone()).isPresent()) continue;
            User u = new User();
            u.setPhone(a.phone());
            u.setFullName(a.name());
            u.setRoleCode(a.role());
            u.setStatus(UserStatus.ACTIVE);
            u.setPhoneVerifiedAt(Instant.now());
            u.setPrivacyConsentAt(Instant.now());
            u.setPasswordHash(encoder.encode(password));
            users.save(u);
            createdAny = true;
        }
        if (createdAny) {
            log.warn("""

                    ===================== DARMAN DEMO ACCOUNTS (fictional, demo mode only) =====================
                      password : {}{}
                      admin      +77000000001   pharmacist +77000000002   operator +77000000003
                      catalog    +77000000004   customer   {}
                    ============================================================================================""",
                    password, generated ? "   (randomly generated; set DARMAN_DEMO_PASSWORD to choose your own)" : "", CUSTOMER_PHONE);
            seedCustomerData();
        }
    }

    private void seedCustomerData() {
        User customer = users.findByPhone(CUSTOMER_PHONE).orElseThrow();
        Address home = new Address();
        home.setUserId(customer.getId());
        home.setLabel("Дом");
        home.setCity("Алматы");
        home.setStreet("ул. Примерная");
        home.setHouse("12");
        home.setApartment("34");
        home.setDefaultAddress(true);
        addresses.save(home);

        try {
            // 1) delivered 6 days ago, delivery from Тау — Достык
            Order o1 = place(customer, "Тау — Достык", List.of("paradem-500-20", "vitc-500-30"), Fulfillment.DELIVERY, home.getId(), PaymentMethod.CASH);
            advance(o1, OrderStatus.DELIVERED);
            backdate(o1, Duration.ofDays(6));
            // 2) delivered 2 days ago, pickup
            Order o2 = place(customer, "Алатау Фарм — Абая", List.of("thermo-digital"), Fulfillment.PICKUP, null, PaymentMethod.CASH);
            advance(o2, OrderStatus.DELIVERED);
            backdate(o2, Duration.ofDays(2));
            // 3) cancelled
            Order o3 = place(customer, "Тау — Достык", List.of("honeydem-tea-20"), Fulfillment.PICKUP, null, PaymentMethod.CASH);
            orders.moveTo(o3.getId(), OrderStatus.CANCELLED, "Demo: cancelled by customer", customer.getId());
            backdate(o3, Duration.ofDays(1));
            // 4) active order out for delivery
            Order o4 = place(customer, "Тау — Достык", List.of("throatdem-24", "nasaldem-saline"), Fulfillment.DELIVERY, home.getId(), PaymentMethod.CASH);
            advance(o4, OrderStatus.IN_TRANSIT);
        } catch (RuntimeException e) {
            log.warn("Demo order seeding skipped: {}", e.getMessage());
        }
    }

    private Order place(User customer, String branchName, List<String> slugs, Fulfillment f, UUID addressId, PaymentMethod pm) {
        List<LineInput> lines = slugs.stream().map(slug -> {
            UUID offerId = jdbc.queryForObject("""
                    select o.id from product_offers o join products p on p.id = o.product_id join pharmacy_branches b on b.id = o.branch_id
                    where p.slug = ? and b.name = ?""", UUID.class, slug, branchName);
            return new LineInput(offerId, 1, null);
        }).toList();
        var req = new PlaceOrderRequest(lines, f, addressId, customer.getFullName(), customer.getPhone(), null, null, pm, null, null, null, true);
        var placed = orders.place(customer.getId(), req, null);
        return orders.find(placed.order().id());
    }


    private void advance(Order o, OrderStatus target) {
        Order current = orders.find(o.getId());
        while (current.getStatus() != target) {
            OrderStatus next = current.getStatus().next(current.getFulfillment());
            orders.moveTo(o.getId(), next, "DEMO: seeded history", null);
            if (next == OrderStatus.IN_TRANSIT) orders.assignDemoCourier(o.getId());
            current = orders.find(o.getId());
        }
    }

    private void backdate(Order o, Duration age) {
        Instant t = Instant.now().minus(age);
        jdbc.update("update orders set created_at = ?, updated_at = ? where id = ?", java.sql.Timestamp.from(t), java.sql.Timestamp.from(t), o.getId());
        jdbc.update("update order_status_history set created_at = ? where order_id = ?", java.sql.Timestamp.from(t), o.getId());
    }

    private static String randomPassword() {
        String alphabet = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        SecureRandom r = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 14; i++) sb.append(alphabet.charAt(r.nextInt(alphabet.length())));
        return sb.append("7a").toString();
    }
}
