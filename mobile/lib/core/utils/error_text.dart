import '../../l10n/l10n_ext.dart';
import '../network/api_failure.dart';

/// Maps backend/transport error codes to localized user messages. Unknown codes fall back to a generic message;
/// raw server text is never shown to the user.
String errorText(AppL10n l, Object error) {
  if (error is! ApiFailure) return l.errUnknown;
  return switch (error.code) {
    'NETWORK' || 'TIMEOUT' => l.errNetwork,
    'INTERNAL_ERROR' => l.errServer,
    'NOT_FOUND' => l.errNotFound,
    'FORBIDDEN' => l.errForbidden,
    'UNAUTHORIZED' => l.errSessionExpired,
    'RATE_LIMITED' => l.errRateLimited,
    'VALIDATION_FAILED' || 'BAD_REQUEST' => l.errValidation,
    'INVALID_CREDENTIALS' => l.errInvalidCredentials,
    'PHONE_NOT_VERIFIED' => l.errPhoneNotVerified,
    'PHONE_ALREADY_REGISTERED' => l.errPhoneExists,
    'WEAK_PASSWORD' => l.errWeakPassword,
    'INVALID_PHONE' => l.errPhoneInvalid,
    'OTP_INVALID' => l.errOtpInvalid,
    'OTP_TOO_SOON' => l.errOtpTooSoon,
    'OTP_PROVIDER_NOT_CONFIGURED' || 'OTP_DELIVERY_FAILED' => l.errOtpUnavailable,
    'ACCOUNT_DISABLED' => l.errAccountDisabled,
    'PRESCRIPTION_REQUIRED' => l.errPrescriptionRequired,
    'PRESCRIPTION_NOT_APPROVED' => l.errPrescriptionNotApproved,
    'PRESCRIPTION_ALREADY_USED' => l.errPrescriptionUsed,
    'INSUFFICIENT_STOCK' || 'OUT_OF_STOCK' => l.errInsufficientStock,
    'OFFER_UNAVAILABLE' => l.errOfferUnavailable,
    'MIXED_BRANCHES' || 'CART_BRANCH_MISMATCH' => l.errMixedBranches,
    'DELIVERY_NOT_AVAILABLE' => l.errDeliveryUnavailable,
    'INVALID_DELIVERY_SLOT' => l.errSlotInvalid,
    'ADDRESS_REQUIRED' => l.errAddressRequired,
    'PAYMENT_PROVIDER_NOT_CONFIGURED' => l.errPaymentUnavailable,
    'PAYMENT_FAILED' => l.errPaymentFailed,
    'CANCEL_NOT_ALLOWED' => l.errCancelNotAllowed,
    'FILE_TOO_LARGE' => l.rxTooLarge(10),
    'UNSUPPORTED_FILE_TYPE' => l.rxBadType,
    'PRESCRIPTION_FILES_REQUIRED' => l.rxNoFiles,
    'PROMO_INVALID' => l.cartPromoInvalid,
    _ => l.errUnknown,
  };
}
