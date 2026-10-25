package kz.darman.identity;

/** Adapter for the phone-verification channel (SMS / messenger gateway). */
public interface OtpProvider {
    /** Delivers the code. Must throw if delivery is impossible; never pretend a message was sent. */
    void send(String phone, String code);

    /** True only for the development adapter that may expose the code to the caller. */
    default boolean exposesCode() {
        return false;
    }
}
