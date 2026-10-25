package kz.darman.identity;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class PermissionService {
    private final JdbcTemplate jdbc;

    public PermissionService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Set<String> permissionsOf(String roleCode) {
        return new HashSet<>(jdbc.queryForList("select permission_code from role_permissions where role_code = ?", String.class, roleCode));
    }

    public List<Map<String, Object>> matrix() {
        return jdbc.queryForList("""
                select r.code as role, r.description,
                       coalesce(array_to_string(array_agg(rp.permission_code order by rp.permission_code)
                                filter (where rp.permission_code is not null), ','), '') as permissions
                from roles r left join role_permissions rp on rp.role_code = r.code
                group by r.code, r.description order by r.code""");
    }

    public boolean roleExists(String code) {
        Integer n = jdbc.queryForObject("select count(*) from roles where code = ?", Integer.class, code);
        return n != null && n > 0;
    }
}
