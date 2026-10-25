package kz.darman.common;

import java.util.regex.Pattern;

public final class Phones {
    private static final Pattern E164_KZ = Pattern.compile("^\\+7\\d{10}$");

    private Phones() {}

    /** Normalizes Kazakhstan/Russia style numbers (8 7xx..., 7 7xx..., +7 7xx...) to +7XXXXXXXXXX. Returns null if invalid. */
    public static String normalize(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("[^0-9]", "");
        if (digits.length() == 11 && (digits.startsWith("8") || digits.startsWith("7"))) {
            digits = "7" + digits.substring(1);
        } else if (digits.length() == 10) {
            digits = "7" + digits;
        } else {
            return null;
        }
        String e164 = "+" + digits;
        return E164_KZ.matcher(e164).matches() ? e164 : null;
    }
}
