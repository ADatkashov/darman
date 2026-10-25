package kz.darman.prescriptions;

/** Detects the real content type from magic bytes; the client-supplied Content-Type is never trusted. */
final class FileSniffer {
    record Detected(String mime, String ext) {}

    private FileSniffer() {}

    static Detected detect(byte[] b) {
        if (b.length >= 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF) return new Detected("image/jpeg", "jpg");
        if (b.length >= 8 && (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G') return new Detected("image/png", "png");
        if (b.length >= 5 && b[0] == '%' && b[1] == 'P' && b[2] == 'D' && b[3] == 'F' && b[4] == '-') return new Detected("application/pdf", "pdf");
        return null;
    }
}
