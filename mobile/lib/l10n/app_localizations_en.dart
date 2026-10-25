// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DARMAN';

  @override
  String get slogan => 'Health nearby';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get ok => 'Got it';

  @override
  String get continueAction => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get seeAll => 'See all';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get free => 'Free';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get clear => 'Clear';

  @override
  String get optional => 'optional';

  @override
  String get required => 'Required field';

  @override
  String get currencySymbol => '₸';

  @override
  String get offlineBanner => 'No internet connection';

  @override
  String get errNetwork => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get errServer => 'Server error. Please try again later.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get errNotFound => 'Not found';

  @override
  String get errForbidden => 'Access denied';

  @override
  String get errRateLimited => 'Too many requests. Please wait a minute.';

  @override
  String get errValidation => 'Please check the entered data';

  @override
  String get errSessionExpired => 'Your session has expired. Please sign in again.';

  @override
  String get medicalDisclaimer =>
      'Information in the app does not replace advice from a doctor or pharmacist. Read the leaflet and consult a professional before use.';

  @override
  String get demoDataNote => 'Demo data: products and pharmacies are fictional.';

  @override
  String get demoModeBanner => 'Demo mode: data is fictional, payment and delivery are not real';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get onb1Title => 'Find the medicine you need';

  @override
  String get onb1Body => 'Search by name, active ingredient, brand or dosage.';

  @override
  String get onb2Title => 'Compare pharmacy prices';

  @override
  String get onb2Body => 'See offers from different pharmacies, availability and delivery terms.';

  @override
  String get onb3Title => 'Prescriptions via a pharmacist';

  @override
  String get onb3Body => 'Upload a photo of your prescription; a pharmacist reviews it where required by law.';

  @override
  String get onb4Title => 'Delivery and tracking';

  @override
  String get onb4Body => 'Follow your order from confirmation to handover.';

  @override
  String get homeSearchHint => 'Search medicines and products';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homePopular => 'Popular products';

  @override
  String get homeFrequent => 'Frequently purchased';

  @override
  String get homeOffers => 'Offers and discounts';

  @override
  String get homeNearby => 'Nearby pharmacies';

  @override
  String get homeRecent => 'Recently viewed';

  @override
  String get homeRxTitle => 'Have a prescription?';

  @override
  String get homeRxBody => 'Upload a photo — a pharmacist will review it';

  @override
  String get homeRxAction => 'Upload prescription';

  @override
  String homeDeliveryInfo(int min, int max) {
    return 'Delivery in Almaty · approx. $min–$max min';
  }

  @override
  String get homeCity => 'City';

  @override
  String get homeCitySoon => 'More cities coming soon';

  @override
  String promoCodeBanner(String code) {
    return 'Promo code $code';
  }

  @override
  String get emptySection => 'Nothing here yet';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Name, ingredient, brand…';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearHistory => 'Clear history';

  @override
  String get searchSuggestions => 'Suggestions';

  @override
  String searchFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count products found', one: '$count product found');
    return '$_temp0';
  }

  @override
  String get searchNoResultsTitle => 'Nothing found';

  @override
  String get searchNoResultsBody => 'Check the spelling or search by active ingredient. We never substitute different products.';

  @override
  String get searchBrowseCategories => 'Browse categories';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortRelevance => 'Relevance';

  @override
  String get sortPriceAsc => 'Price: low to high';

  @override
  String get sortPriceDesc => 'Price: high to low';

  @override
  String get sortPopularity => 'Popularity';

  @override
  String get filters => 'Filters';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterManufacturer => 'Manufacturer';

  @override
  String get filterAll => 'All';

  @override
  String get filterInStock => 'In stock only';

  @override
  String get filterPrice => 'Price, ₸';

  @override
  String get filterPriceFrom => 'From';

  @override
  String get filterPriceTo => 'To';

  @override
  String get filterRx => 'Prescription';

  @override
  String get filterRxAny => 'Any';

  @override
  String get filterRxOnly => 'Prescription only';

  @override
  String get filterRxNone => 'Without prescription';

  @override
  String get loadMore => 'Load more';

  @override
  String get searchClearSemantic => 'Clear search';

  @override
  String get productTitle => 'Product';

  @override
  String get prodBrand => 'Brand';

  @override
  String get prodIngredient => 'Active ingredient';

  @override
  String get prodStrength => 'Strength';

  @override
  String get prodForm => 'Dosage form';

  @override
  String get prodPackage => 'Package';

  @override
  String get prodManufacturer => 'Manufacturer';

  @override
  String get prodDescription => 'Description';

  @override
  String get prodUsage => 'Usage';

  @override
  String get prodStorage => 'Storage';

  @override
  String get prodWarnings => 'Warnings';

  @override
  String get prodContraindications => 'Contraindications';

  @override
  String get prodComposition => 'Composition';

  @override
  String get prodInfoUnavailable => 'Official instructions are not available. Read the package leaflet and consult a professional.';

  @override
  String prodInfoSource(String source) {
    return 'Source: $source';
  }

  @override
  String get badgeRx => 'Prescription';

  @override
  String get badgeOtc => 'OTC';

  @override
  String get rxNeededNote => 'An approved prescription is required to order this product.';

  @override
  String get offersTitle => 'Pharmacy offers';

  @override
  String get offersBestPrice => 'Best price';

  @override
  String get offersNone => 'No offers in your city right now';

  @override
  String get offerPickup => 'Pickup';

  @override
  String get offerDelivery => 'Delivery';

  @override
  String get offerNoDelivery => 'No delivery';

  @override
  String offerDeliveryFee(String fee) {
    return 'Delivery $fee';
  }

  @override
  String offerFreeFrom(String amount) {
    return 'free from $amount';
  }

  @override
  String offerEta(int min, int max) {
    return '≈ $min–$max min (estimate)';
  }

  @override
  String offerUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get stockIn => 'In stock';

  @override
  String get stockLow => 'Low stock';

  @override
  String get stockOut => 'Out of stock';

  @override
  String stockCount(int count) {
    return 'In stock: $count pcs';
  }

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get selectOffer => 'Select';

  @override
  String get offerSelected => 'Selected';

  @override
  String priceFrom(String price) {
    return 'from $price';
  }

  @override
  String get quantityDecrease => 'Decrease quantity';

  @override
  String get quantityIncrease => 'Increase quantity';

  @override
  String quantityLabel(int count) {
    return 'Quantity: $count';
  }

  @override
  String get unavailableOffer => 'Offer unavailable';

  @override
  String get pharmacyDemoNote => 'Fictional pharmacy (demo)';

  @override
  String get licenseNotVerified => 'Licence not verified (demo data)';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Find products in the catalog and add them to your cart';

  @override
  String get goToCatalog => 'Go to catalog';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count items', one: '$count item');
    return '$_temp0';
  }

  @override
  String cartPharmacy(String name) {
    return 'Pharmacy: $name';
  }

  @override
  String get cartPromo => 'Promo code';

  @override
  String get cartPromoHint => 'Enter promo code';

  @override
  String cartPromoApplied(String amount) {
    return 'Promo code applied: −$amount';
  }

  @override
  String get cartPromoInvalid => 'Promo code can\'t be applied';

  @override
  String get cartPromoMin => 'Order total is below the promo minimum';

  @override
  String get cartSubtotal => 'Items';

  @override
  String get cartDelivery => 'Delivery';

  @override
  String get cartDiscount => 'Discount';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckout => 'Checkout';

  @override
  String get cartClear => 'Clear cart';

  @override
  String get cartClearConfirm => 'Remove all items from the cart?';

  @override
  String get cartBranchMismatchTitle => 'Items from another pharmacy';

  @override
  String cartBranchMismatchBody(String name) {
    return 'An order is fulfilled by a single pharmacy. Your cart has items from “$name”. Replace the cart?';
  }

  @override
  String get cartReplace => 'Replace';

  @override
  String get cartKeep => 'Keep';

  @override
  String cartIssuePrice(String old, String now) {
    return 'Price changed: was $old, now $now';
  }

  @override
  String get cartIssueOut => 'Out of stock';

  @override
  String cartIssueLow(int count) {
    return 'Only $count available';
  }

  @override
  String get cartIssueUnavailable => 'This offer is no longer available';

  @override
  String get cartFixIssues => 'Remove unavailable items or adjust quantities';

  @override
  String get cartCheckFailed => 'Couldn\'t verify availability and prices. They will be re-checked at checkout.';

  @override
  String get cartRxNeeded => 'Your cart has prescription items — an approved prescription is required';

  @override
  String cartFreeDeliveryFrom(String amount) {
    return 'Free delivery from $amount';
  }

  @override
  String get cartDeliveryUnavailable => 'This pharmacy doesn\'t deliver — pickup only';

  @override
  String cartRemoveItem(String name) {
    return 'Remove $name from cart';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get coContact => 'Contact';

  @override
  String get coName => 'Recipient name';

  @override
  String get coPhone => 'Phone';

  @override
  String get coFulfillment => 'How to receive';

  @override
  String get coDelivery => 'Delivery';

  @override
  String get coPickup => 'Pickup';

  @override
  String coPickupFrom(String address) {
    return 'Collect at the pharmacy: $address';
  }

  @override
  String get coAddress => 'Delivery address';

  @override
  String get coChooseAddress => 'Choose an address';

  @override
  String get coAddAddress => 'Add address';

  @override
  String get coNotes => 'Note for the courier';

  @override
  String get coSlot => 'Delivery time';

  @override
  String coAsap(int min, int max) {
    return 'As soon as possible · ≈ $min–$max min (estimate)';
  }

  @override
  String get coSlotToday => 'Today';

  @override
  String get coSlotTomorrow => 'Tomorrow';

  @override
  String get coPayment => 'Payment';

  @override
  String get coPayCash => 'Cash on receipt';

  @override
  String get coPayCard => 'Card online';

  @override
  String get coPayCardDemo => 'Card online — DEMO (no money is charged)';

  @override
  String get coPayCardUnavailable => 'Online payment is currently unavailable';

  @override
  String get coRxSection => 'Prescription';

  @override
  String get coRxChoose => 'Choose an approved prescription';

  @override
  String get coRxNone => 'No approved prescriptions. Upload one and wait for pharmacist review.';

  @override
  String get coRxUpload => 'Upload prescription';

  @override
  String coRxLine(String date) {
    return 'Prescription from $date';
  }

  @override
  String get coConsent => 'I agree to the Privacy Policy and Terms of Service';

  @override
  String get coConsentRequired => 'Consent is required to place the order';

  @override
  String coPlaceOrder(String total) {
    return 'Place order · $total';
  }

  @override
  String get coPlacing => 'Placing…';

  @override
  String get coSummary => 'Your order';

  @override
  String get coPriceChangedTitle => 'Prices changed';

  @override
  String get coPriceChangedBody => 'Prices or availability changed while you were checking out. Review your cart and try again.';

  @override
  String get coDoneTitle => 'Order placed';

  @override
  String coDoneBody(String number) {
    return 'Order number: $number';
  }

  @override
  String get coDoneDemo => 'Demo order: no real payment or delivery takes place';

  @override
  String get coViewOrder => 'Track order';

  @override
  String get coBackHome => 'Back to home';

  @override
  String get coLoginRequired => 'Sign in to place an order';

  @override
  String get errPrescriptionRequired => 'These items need an approved prescription';

  @override
  String get errPrescriptionNotApproved => 'The prescription isn\'t approved or has expired';

  @override
  String get errPrescriptionUsed => 'This prescription has already been used';

  @override
  String get errInsufficientStock => 'Not enough stock available';

  @override
  String get errOfferUnavailable => 'One of the items is no longer available';

  @override
  String get errMixedBranches => 'Items must come from a single pharmacy';

  @override
  String get errDeliveryUnavailable => 'This pharmacy doesn\'t deliver';

  @override
  String get errSlotInvalid => 'The selected delivery time is no longer available';

  @override
  String get errAddressRequired => 'Select a delivery address';

  @override
  String get errPaymentUnavailable => 'Online payment is unavailable. Choose cash on receipt.';

  @override
  String get errPaymentFailed => 'Payment was declined';

  @override
  String get errPhoneInvalid => 'Enter a number like +7 XXX XXX XX XX';

  @override
  String get errCancelNotAllowed => 'This order can no longer be cancelled';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersActive => 'Current';

  @override
  String get ordersHistory => 'History';

  @override
  String get ordersEmptyActive => 'No current orders';

  @override
  String get ordersEmptyHistory => 'No past orders';

  @override
  String get ordersGuestTitle => 'Sign in to see your orders';

  @override
  String get ordersGuestBody => 'Your orders and their statuses will appear here';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String get orderDetails => 'Order details';

  @override
  String get orderDelivery => 'Delivery';

  @override
  String get orderTracking => 'Tracking';

  @override
  String get statusPlaced => 'Order placed';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusReadyForPickup => 'Ready for pickup';

  @override
  String get statusInTransit => 'In transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusDeliveredPickup => 'Collected';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusInTransitHint => 'The courier is on the way';

  @override
  String get statusPreparingHint => 'The pharmacy is preparing your order';

  @override
  String get orderWindow => 'Delivery window';

  @override
  String orderEtaEstimate(String from, String to) {
    return 'Estimated $from–$to';
  }

  @override
  String get orderAddress => 'Delivery address';

  @override
  String get orderPickupAddress => 'Pickup point';

  @override
  String get orderCourier => 'Courier';

  @override
  String get orderCourierDemo => 'Demo courier (fictional)';

  @override
  String get orderCall => 'Call';

  @override
  String get orderNoCourier => 'A courier is assigned before dispatch';

  @override
  String get orderItems => 'Items';

  @override
  String get orderSupport => 'Support';

  @override
  String get orderSupportBody => 'Need help with your order? Contact the pharmacy or support.';

  @override
  String get orderContactPharmacy => 'Contact pharmacy';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String get orderCancelConfirm => 'Cancel this order? Items will be returned to stock.';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get orderReceipt => 'Receipt';

  @override
  String get orderReceiptNotice => 'This is an order summary, not a fiscal receipt.';

  @override
  String get orderReorder => 'Reorder';

  @override
  String orderReorderDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(added, locale: localeName, other: '$added items added to cart', one: '$added item added to cart');
    return '$_temp0';
  }

  @override
  String orderReorderSkipped(int count) {
    return 'Some items are unavailable and were skipped: $count';
  }

  @override
  String get orderReorderChanged => 'Prices or quantities changed — please review your cart';

  @override
  String get orderHistoryTitle => 'Status history';

  @override
  String get payUnpaid => 'Pay on receipt';

  @override
  String get payPending => 'Awaiting payment';

  @override
  String get payPaid => 'Paid';

  @override
  String get payDemoPaid => 'Demo payment (no money charged)';

  @override
  String get payFailed => 'Payment failed';

  @override
  String get payRefundPending => 'Refund pending';

  @override
  String get payRefunded => 'Refunded';

  @override
  String get orderPayment => 'Payment';

  @override
  String get orderFulfillmentDelivery => 'Delivery';

  @override
  String get orderFulfillmentPickup => 'Pickup';

  @override
  String get orderSimulatedNote => 'Demo order statuses advance automatically for demonstration. No real courier or GPS is connected.';

  @override
  String get rxTitle => 'Prescriptions';

  @override
  String get rxUploadTitle => 'Upload prescription';

  @override
  String rxUploadHint(int size) {
    return 'Photos and PDF (JPG, PNG, PDF) up to $size MB';
  }

  @override
  String get rxLegal => 'A pharmacist reviews the prescription. Uploading a file does not mean approval.';

  @override
  String get rxTakePhoto => 'Take a photo';

  @override
  String get rxGallery => 'From gallery';

  @override
  String get rxPdf => 'Choose PDF';

  @override
  String get rxAddMore => 'Add more';

  @override
  String get rxNote => 'Note (optional)';

  @override
  String get rxSubmit => 'Submit for review';

  @override
  String rxUploading(int percent) {
    return 'Uploading $percent%';
  }

  @override
  String get rxSubmittedOk => 'Prescription submitted for review';

  @override
  String get rxStatusDraft => 'Draft';

  @override
  String get rxStatusSubmitted => 'Submitted';

  @override
  String get rxStatusUnderReview => 'Under review';

  @override
  String get rxStatusApproved => 'Approved';

  @override
  String get rxStatusRejected => 'Rejected';

  @override
  String get rxStatusExpired => 'Expired';

  @override
  String rxRejectionReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String rxValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get rxHistory => 'My prescriptions';

  @override
  String get rxEmpty => 'You haven\'t uploaded any prescriptions';

  @override
  String rxFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count files', one: '$count file');
    return '$_temp0';
  }

  @override
  String rxTooLarge(int size) {
    return 'File is larger than $size MB';
  }

  @override
  String get rxBadType => 'Only JPG, PNG and PDF are allowed';

  @override
  String rxMaxFiles(int count) {
    return 'At most $count files';
  }

  @override
  String get rxNoFiles => 'Add at least one file';

  @override
  String get rxDemoReview => 'Demo review: this is not a check by a real pharmacist';

  @override
  String get rxTimeline => 'Review progress';

  @override
  String get rxEventCreated => 'Draft created';

  @override
  String get rxEventSubmitted => 'Submitted for review';

  @override
  String get rxEventReviewStarted => 'Review started';

  @override
  String get rxEventApproved => 'Prescription approved';

  @override
  String get rxEventRejected => 'Prescription rejected';

  @override
  String get rxEventExpired => 'Validity expired';

  @override
  String get rxUsable => 'Can be used in an order';

  @override
  String get rxDeleteDraft => 'Delete draft';

  @override
  String get rxLoginRequired => 'Sign in to upload a prescription';

  @override
  String get rxFileRemove => 'Remove file';

  @override
  String get rxNewShort => 'New prescription';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Sign in with your phone number';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'We\'ll verify your number with a code';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'At least 8 characters, letters and digits';

  @override
  String get authFullName => 'Name';

  @override
  String get authConsent => 'I accept the Privacy Policy and consent to processing of personal data';

  @override
  String get authConsentRequired => 'Consent to data processing is required';

  @override
  String get authLoginAction => 'Sign in';

  @override
  String get authRegisterAction => 'Register';

  @override
  String get authNoAccount => 'No account? Register';

  @override
  String get authHaveAccount => 'Have an account? Sign in';

  @override
  String get authContinueGuest => 'Continue as guest';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpBody(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String otpDemoNote(String code) {
    return 'DEMO: your code is $code. In production the code arrives by SMS.';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpCode => 'SMS code';

  @override
  String get errInvalidCredentials => 'Invalid phone or password';

  @override
  String get errPhoneNotVerified => 'Phone number isn\'t verified. Finish registration.';

  @override
  String get errPhoneExists => 'This number is already registered';

  @override
  String get errWeakPassword => 'Password needs letters and digits (8+ characters)';

  @override
  String get errOtpInvalid => 'Invalid or expired code';

  @override
  String get errOtpTooSoon => 'A code was just sent. Please wait a moment.';

  @override
  String get errOtpUnavailable => 'SMS verification is currently unavailable';

  @override
  String get errAccountDisabled => 'Account is disabled';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuestTitle => 'Welcome to DARMAN';

  @override
  String get profileGuestBody => 'Sign in to place orders and save addresses and prescriptions';

  @override
  String get profileLoginRegister => 'Sign in or register';

  @override
  String get profileMyOrders => 'My orders';

  @override
  String get profileRx => 'Prescriptions';

  @override
  String get profileAddresses => 'Delivery addresses';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profileTerms => 'Terms of service';

  @override
  String get profileHelp => 'Help and support';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLogoutConfirm => 'Sign out of your account?';

  @override
  String get profileDelete => 'Delete account';

  @override
  String get profileDeleteBody =>
      'We\'ll record a request to delete your account and personal data. Records that must be kept by law may be retained in anonymised form. You can cancel the request.';

  @override
  String get profileDeleteRequested => 'Deletion request recorded';

  @override
  String get profileDeletePending => 'Account deletion requested';

  @override
  String get profileDeleteCancel => 'Cancel deletion request';

  @override
  String get profileEdit => 'Personal details';

  @override
  String get profileFullName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileEmailInvalid => 'Invalid email';

  @override
  String get profileSaved => 'Saved';

  @override
  String get notifSettings => 'Notification settings';

  @override
  String get notifOrders => 'Order updates';

  @override
  String get notifPrescriptions => 'Prescription review';

  @override
  String get notifPromotions => 'Promotions and offers';

  @override
  String get notifInbox => 'Notification inbox';

  @override
  String get notifEmpty => 'No notifications yet';

  @override
  String get notifRxApproved => 'Prescription approved';

  @override
  String get notifRxRejected => 'Prescription rejected';

  @override
  String get notifRxReview => 'Prescription under review';

  @override
  String get notifOrderPlaced => 'Order placed';

  @override
  String get notifOrderUpdate => 'Order status changed';

  @override
  String get notifOrderCancelled => 'Order cancelled';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get languageTitle => 'App language';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get languageEn => 'English';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptyBody => 'Tap the heart on a product to save it';

  @override
  String get favoritesGuestNote => 'Favorites are stored on this device. Sign in to keep them in your account.';

  @override
  String get addressesTitle => 'Delivery addresses';

  @override
  String get addressesEmpty => 'No addresses yet';

  @override
  String get addressAdd => 'Add address';

  @override
  String get addressEdit => 'Edit address';

  @override
  String get addressLabel => 'Label (Home, Work…)';

  @override
  String get addressCity => 'City';

  @override
  String get addressStreet => 'Street';

  @override
  String get addressHouse => 'House';

  @override
  String get addressApartment => 'Apartment';

  @override
  String get addressEntrance => 'Entrance';

  @override
  String get addressFloor => 'Floor';

  @override
  String get addressComment => 'Comment';

  @override
  String get addressDefault => 'Default address';

  @override
  String get addressDefaultBadge => 'Default';

  @override
  String get addressDeleteConfirm => 'Delete this address?';

  @override
  String get pharmaciesTitle => 'Pharmacies';

  @override
  String pharmacyHours(String hours) {
    return 'Hours: $hours';
  }

  @override
  String pharmacyDistance(String km) {
    return '$km km';
  }

  @override
  String get pharmacyDelivers => 'Delivers';

  @override
  String get pharmacyPickupOnly => 'Pickup only';

  @override
  String get pharmacyCall => 'Call pharmacy';

  @override
  String get pharmacyProducts => 'Pharmacy products';

  @override
  String get legalDraftNote => 'Draft text. Requires review by legal and pharmacy professionals before launch.';

  @override
  String get privacyBody =>
      'DARMAN processes your phone number, name, delivery addresses, order history and, if you choose, prescription photos — only to place and fulfil orders, let a pharmacist review prescriptions and provide support. Prescription files are kept in private storage; only you and an authorised pharmacist can access them and every access is logged. You can request deletion of your account and data at any time in Profile. We do not sell personal data.';

  @override
  String get termsBody =>
      'DARMAN is a service for finding products and placing orders with partner pharmacies. Prescription-only products are released only after a pharmacist reviews the prescription. Information in the app is for reference and does not replace professional advice. Availability, prices and delivery times are set by the pharmacy; stated delivery times are estimates. An order can be cancelled until the pharmacy starts preparing it.';

  @override
  String get helpTitle => 'Help and support';

  @override
  String get helpFaqRxQ => 'How do I order a prescription medicine?';

  @override
  String get helpFaqRxA => 'Upload a photo in Prescriptions. Once a pharmacist approves it, select it at checkout.';

  @override
  String get helpFaqDeliveryQ => 'How does delivery work?';

  @override
  String get helpFaqDeliveryA =>
      'A single pharmacy fulfils each order. Delivery times are estimates; the status updates as the order is prepared and handed to a courier.';

  @override
  String get helpFaqPayQ => 'How do I pay?';

  @override
  String get helpFaqPayA =>
      'Pay on receipt is available. Online card payment appears once a payment provider is connected; in demo mode no money is charged.';

  @override
  String get helpContact => 'Contact support';

  @override
  String get helpNoPhone => 'Support contacts are not configured yet';

  @override
  String get helpEmergency => 'In an emergency call 103 immediately.';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';
}
