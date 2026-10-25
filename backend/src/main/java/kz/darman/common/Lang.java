package kz.darman.common;

import java.util.Set;
import org.springframework.context.i18n.LocaleContextHolder;

public final class Lang {
    public static final Set<String> SUPPORTED = Set.of("ru", "kk", "en");

    private Lang() {}

    /** Resolves ru/kk/en from an explicit parameter or the request Accept-Language header (default ru). */
    public static String resolve(String explicit) {
        if (explicit != null && SUPPORTED.contains(explicit.toLowerCase())) return explicit.toLowerCase();
        String l = LocaleContextHolder.getLocale().getLanguage();
        return SUPPORTED.contains(l) ? l : "ru";
    }

    public static String pick(String lang, String ru, String kk, String en) {
        String v = switch (lang) {
            case "kk" -> kk;
            case "en" -> en;
            default -> ru;
        };
        if (v == null || v.isBlank()) v = ru != null && !ru.isBlank() ? ru : (en != null ? en : kk);
        return v;
    }
}
