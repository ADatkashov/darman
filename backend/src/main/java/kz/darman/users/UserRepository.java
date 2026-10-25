package kz.darman.users;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByPhone(String phone);

    @Query("select u from User u where u.roleCode <> 'CUSTOMER' order by u.createdAt desc")
    Page<User> findStaff(Pageable pageable);
}
