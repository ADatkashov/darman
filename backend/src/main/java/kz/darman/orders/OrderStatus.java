package kz.darman.orders;

public enum OrderStatus {
    PLACED, CONFIRMED, PREPARING, READY_FOR_PICKUP, IN_TRANSIT, DELIVERED, CANCELLED;

    public boolean isTerminal() {
        return this == DELIVERED || this == CANCELLED;
    }

    /** Next forward status in the happy path for the given fulfillment type, or null if terminal. */
    public OrderStatus next(Fulfillment f) {
        return switch (this) {
            case PLACED -> CONFIRMED;
            case CONFIRMED -> PREPARING;
            case PREPARING -> f == Fulfillment.PICKUP ? READY_FOR_PICKUP : IN_TRANSIT;
            case READY_FOR_PICKUP, IN_TRANSIT -> DELIVERED;
            default -> null;
        };
    }
}
