// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppL10nKk extends AppL10n {
  AppL10nKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'DARMAN';

  @override
  String get slogan => 'Денсаулық жақын';

  @override
  String get retry => 'Қайталау';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get save => 'Сақтау';

  @override
  String get delete => 'Жою';

  @override
  String get edit => 'Өзгерту';

  @override
  String get close => 'Жабу';

  @override
  String get ok => 'Түсінікті';

  @override
  String get continueAction => 'Жалғастыру';

  @override
  String get back => 'Артқа';

  @override
  String get skip => 'Өткізіп жіберу';

  @override
  String get next => 'Келесі';

  @override
  String get getStarted => 'Бастау';

  @override
  String get apply => 'Қолдану';

  @override
  String get reset => 'Қалпына келтіру';

  @override
  String get seeAll => 'Барлығын көру';

  @override
  String get add => 'Қосу';

  @override
  String get remove => 'Алып тастау';

  @override
  String get confirm => 'Растау';

  @override
  String get yes => 'Иә';

  @override
  String get no => 'Жоқ';

  @override
  String get free => 'Тегін';

  @override
  String get demoBadge => 'ДЕМО';

  @override
  String get clear => 'Тазалау';

  @override
  String get optional => 'міндетті емес';

  @override
  String get required => 'Міндетті өріс';

  @override
  String get currencySymbol => '₸';

  @override
  String get offlineBanner => 'Интернет байланысы жоқ';

  @override
  String get errNetwork => 'Серверге қосыла алмадық. Интернетті тексеріп, қайталаңыз.';

  @override
  String get errServer => 'Сервер қатесі. Кейінірек қайталаңыз.';

  @override
  String get errUnknown => 'Бірдеңе дұрыс болмады. Қайталап көріңіз.';

  @override
  String get errNotFound => 'Табылмады';

  @override
  String get errForbidden => 'Рұқсат жеткіліксіз';

  @override
  String get errRateLimited => 'Сұраныс тым көп. Бір минут күтіңіз.';

  @override
  String get errValidation => 'Енгізілген деректерді тексеріңіз';

  @override
  String get errSessionExpired => 'Сессия аяқталды. Қайта кіріңіз.';

  @override
  String get medicalDisclaimer =>
      'Қосымшадағы ақпарат дәрігердің немесе фармацевтің кеңесін алмастырмайды. Қолданар алдында нұсқаулықты оқып, маманмен кеңесіңіз.';

  @override
  String get demoDataNote => 'Демонстрациялық деректер: тауарлар мен дәріханалар ойдан шығарылған.';

  @override
  String get demoModeBanner => 'Демо-режим: деректер ойдан шығарылған, төлем мен жеткізу шынайы емес';

  @override
  String get navHome => 'Басты бет';

  @override
  String get navSearch => 'Іздеу';

  @override
  String get navCart => 'Себет';

  @override
  String get navOrders => 'Тапсырыстар';

  @override
  String get navProfile => 'Профиль';

  @override
  String get onb1Title => 'Қажетті дәріні табыңыз';

  @override
  String get onb1Body => 'Атауы, әсер етуші заты, бренді немесе дозасы бойынша іздеңіз.';

  @override
  String get onb2Title => 'Дәріхана бағаларын салыстырыңыз';

  @override
  String get onb2Body => 'Әртүрлі дәріханалардың ұсыныстарын, қолжетімділікті және жеткізу шарттарын көріңіз.';

  @override
  String get onb3Title => 'Рецепт — фармацевт арқылы';

  @override
  String get onb3Body => 'Рецепт суретін жүктеңіз: заңда көзделген жағдайда оны фармацевт тексереді.';

  @override
  String get onb4Title => 'Жеткізу және бақылау';

  @override
  String get onb4Body => 'Тапсырыс мәртебесін растаудан алғанға дейін бақылаңыз.';

  @override
  String get homeSearchHint => 'Дәрі мен тауарларды іздеу';

  @override
  String get homeCategories => 'Санаттар';

  @override
  String get homePopular => 'Танымал тауарлар';

  @override
  String get homeFrequent => 'Жиі сатып алады';

  @override
  String get homeOffers => 'Акциялар мен жеңілдіктер';

  @override
  String get homeNearby => 'Жақын дәріханалар';

  @override
  String get homeRecent => 'Сіз қарағандар';

  @override
  String get homeRxTitle => 'Рецептіңіз бар ма?';

  @override
  String get homeRxBody => 'Суретті жүктеңіз — фармацевт рецептті тексереді';

  @override
  String get homeRxAction => 'Рецепт жүктеу';

  @override
  String homeDeliveryInfo(int min, int max) {
    return 'Алматы бойынша жеткізу · шамамен $min–$max мин';
  }

  @override
  String get homeCity => 'Қала';

  @override
  String get homeCitySoon => 'Басқа қалалар жақында қосылады';

  @override
  String promoCodeBanner(String code) {
    return 'Промокод $code';
  }

  @override
  String get emptySection => 'Әзірге ештеңе жоқ';

  @override
  String get searchTitle => 'Іздеу';

  @override
  String get searchHint => 'Атауы, зат, бренд…';

  @override
  String get searchRecent => 'Соңғы сұраулар';

  @override
  String get searchClearHistory => 'Тарихты тазалау';

  @override
  String get searchSuggestions => 'Ұсыныстар';

  @override
  String searchFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count тауар табылды', one: '$count тауар табылды');
    return '$_temp0';
  }

  @override
  String get searchNoResultsTitle => 'Ештеңе табылмады';

  @override
  String get searchNoResultsBody =>
      'Жазылуын тексеріңіз немесе әсер етуші зат бойынша іздеңіз. Біз ұқсас, бірақ басқа тауарларды ұсынбаймыз.';

  @override
  String get searchBrowseCategories => 'Санаттарды қарау';

  @override
  String get sortLabel => 'Сұрыптау';

  @override
  String get sortRelevance => 'Сәйкестігі бойынша';

  @override
  String get sortPriceAsc => 'Алдымен арзандары';

  @override
  String get sortPriceDesc => 'Алдымен қымбаттары';

  @override
  String get sortPopularity => 'Танымалдығы бойынша';

  @override
  String get filters => 'Сүзгілер';

  @override
  String get filterCategory => 'Санат';

  @override
  String get filterManufacturer => 'Өндіруші';

  @override
  String get filterAll => 'Барлығы';

  @override
  String get filterInStock => 'Тек қолда бары';

  @override
  String get filterPrice => 'Баға, ₸';

  @override
  String get filterPriceFrom => 'Бастап';

  @override
  String get filterPriceTo => 'Дейін';

  @override
  String get filterRx => 'Рецепт бойынша';

  @override
  String get filterRxAny => 'Кез келген';

  @override
  String get filterRxOnly => 'Тек рецепт бойынша';

  @override
  String get filterRxNone => 'Рецептсіз';

  @override
  String get loadMore => 'Тағы жүктеу';

  @override
  String get searchClearSemantic => 'Іздеуді тазалау';

  @override
  String get productTitle => 'Тауар';

  @override
  String get prodBrand => 'Бренд';

  @override
  String get prodIngredient => 'Әсер етуші зат';

  @override
  String get prodStrength => 'Дозасы';

  @override
  String get prodForm => 'Шығарылу түрі';

  @override
  String get prodPackage => 'Орама';

  @override
  String get prodManufacturer => 'Өндіруші';

  @override
  String get prodDescription => 'Сипаттама';

  @override
  String get prodUsage => 'Қолдану тәсілі';

  @override
  String get prodStorage => 'Сақтау шарттары';

  @override
  String get prodWarnings => 'Ескертулер';

  @override
  String get prodContraindications => 'Қарсы көрсетілімдер';

  @override
  String get prodComposition => 'Құрамы';

  @override
  String get prodInfoUnavailable => 'Ресми нұсқаулық қолжетімсіз. Қаптамадағы нұсқаулықты оқып, маманмен кеңесіңіз.';

  @override
  String prodInfoSource(String source) {
    return 'Дереккөз: $source';
  }

  @override
  String get badgeRx => 'Рецепт бойынша';

  @override
  String get badgeOtc => 'Рецептсіз';

  @override
  String get rxNeededNote => 'Тапсырыс беру үшін фармацевт мақұлдаған рецепт қажет.';

  @override
  String get offersTitle => 'Дәріхана ұсыныстары';

  @override
  String get offersBestPrice => 'Үздік баға';

  @override
  String get offersNone => 'Қазір қалаңызда ұсыныс жоқ';

  @override
  String get offerPickup => 'Өзі алып кету';

  @override
  String get offerDelivery => 'Жеткізу';

  @override
  String get offerNoDelivery => 'Жеткізусіз';

  @override
  String offerDeliveryFee(String fee) {
    return 'Жеткізу $fee';
  }

  @override
  String offerFreeFrom(String amount) {
    return '$amount бастап тегін';
  }

  @override
  String offerEta(int min, int max) {
    return '≈ $min–$max мин (болжам)';
  }

  @override
  String offerUpdated(String time) {
    return 'Жаңартылды $time';
  }

  @override
  String get stockIn => 'Қолда бар';

  @override
  String get stockLow => 'Аз қалды';

  @override
  String get stockOut => 'Қолда жоқ';

  @override
  String stockCount(int count) {
    return 'Қолда: $count дана';
  }

  @override
  String get addToCart => 'Себетке';

  @override
  String get addedToCart => 'Себетке қосылды';

  @override
  String get viewCart => 'Ашу';

  @override
  String get favoriteAdd => 'Таңдаулыға қосу';

  @override
  String get favoriteRemove => 'Таңдаулыдан алып тастау';

  @override
  String get selectOffer => 'Таңдау';

  @override
  String get offerSelected => 'Таңдалды';

  @override
  String priceFrom(String price) {
    return '$price бастап';
  }

  @override
  String get quantityDecrease => 'Санын азайту';

  @override
  String get quantityIncrease => 'Санын арттыру';

  @override
  String quantityLabel(int count) {
    return 'Саны: $count';
  }

  @override
  String get unavailableOffer => 'Ұсыныс қолжетімсіз';

  @override
  String get pharmacyDemoNote => 'Ойдан шығарылған дәріхана (демо)';

  @override
  String get licenseNotVerified => 'Лицензия тексерілмеген (демо-деректер)';

  @override
  String get cartTitle => 'Себет';

  @override
  String get cartEmptyTitle => 'Себет әзірге бос';

  @override
  String get cartEmptyBody => 'Қажетті тауарларды каталогтан тауып, себетке қосыңыз';

  @override
  String get goToCatalog => 'Каталогқа өту';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count тауар', one: '$count тауар');
    return '$_temp0';
  }

  @override
  String cartPharmacy(String name) {
    return 'Дәріхана: $name';
  }

  @override
  String get cartPromo => 'Промокод';

  @override
  String get cartPromoHint => 'Промокодты енгізіңіз';

  @override
  String cartPromoApplied(String amount) {
    return 'Промокод қолданылды: −$amount';
  }

  @override
  String get cartPromoInvalid => 'Промокод жарамсыз';

  @override
  String get cartPromoMin => 'Промокод үшін тапсырыстың ең аз сомасына жетпедіңіз';

  @override
  String get cartSubtotal => 'Тауарлар';

  @override
  String get cartDelivery => 'Жеткізу';

  @override
  String get cartDiscount => 'Жеңілдік';

  @override
  String get cartTotal => 'Барлығы';

  @override
  String get cartCheckout => 'Тапсырыс беру';

  @override
  String get cartClear => 'Себетті тазалау';

  @override
  String get cartClearConfirm => 'Себеттегі барлық тауарды жою керек пе?';

  @override
  String get cartBranchMismatchTitle => 'Басқа дәріхананың тауарлары';

  @override
  String cartBranchMismatchBody(String name) {
    return 'Тапсырысты бір дәріхана орындайды. Себетте «$name» тауарлары бар. Себетті ауыстыру керек пе?';
  }

  @override
  String get cartReplace => 'Ауыстыру';

  @override
  String get cartKeep => 'Қалдыру';

  @override
  String cartIssuePrice(String old, String now) {
    return 'Баға өзгерді: $old болған, енді $now';
  }

  @override
  String get cartIssueOut => 'Қолда жоқ';

  @override
  String cartIssueLow(int count) {
    return 'Тек $count дана бар';
  }

  @override
  String get cartIssueUnavailable => 'Ұсыныс енді қолжетімсіз';

  @override
  String get cartFixIssues => 'Қолжетімсіз тауарларды алып тастаңыз немесе санын өзгертіңіз';

  @override
  String get cartCheckFailed => 'Қолжетімділік пен бағаны тексере алмадық. Тапсырыс беру кезінде қайта тексеріледі.';

  @override
  String get cartRxNeeded => 'Себетте рецепт бойынша тауарлар бар — тапсырыс үшін мақұлданған рецепт қажет';

  @override
  String cartFreeDeliveryFrom(String amount) {
    return '$amount бастап тегін жеткізу';
  }

  @override
  String get cartDeliveryUnavailable => 'Бұл дәріхана жеткізбейді — өзі алып кету қолжетімді';

  @override
  String cartRemoveItem(String name) {
    return '$name тауарын себеттен жою';
  }

  @override
  String get checkoutTitle => 'Тапсырысты рәсімдеу';

  @override
  String get coContact => 'Байланыс';

  @override
  String get coName => 'Алушының аты';

  @override
  String get coPhone => 'Телефон';

  @override
  String get coFulfillment => 'Алу тәсілі';

  @override
  String get coDelivery => 'Жеткізу';

  @override
  String get coPickup => 'Өзі алып кету';

  @override
  String coPickupFrom(String address) {
    return 'Дәріханадан алыңыз: $address';
  }

  @override
  String get coAddress => 'Жеткізу мекенжайы';

  @override
  String get coChooseAddress => 'Мекенжайды таңдаңыз';

  @override
  String get coAddAddress => 'Мекенжай қосу';

  @override
  String get coNotes => 'Курьерге пікір';

  @override
  String get coSlot => 'Жеткізу уақыты';

  @override
  String coAsap(int min, int max) {
    return 'Мүмкіндігінше тез · ≈ $min–$max мин (болжам)';
  }

  @override
  String get coSlotToday => 'Бүгін';

  @override
  String get coSlotTomorrow => 'Ертең';

  @override
  String get coPayment => 'Төлем';

  @override
  String get coPayCash => 'Алған кезде қолма-қол';

  @override
  String get coPayCard => 'Банк картасымен онлайн';

  @override
  String get coPayCardDemo => 'Карта онлайн — ДЕМО (ақша есептен шығарылмайды)';

  @override
  String get coPayCardUnavailable => 'Онлайн төлем қазір қолжетімсіз';

  @override
  String get coRxSection => 'Рецепт';

  @override
  String get coRxChoose => 'Мақұлданған рецептті таңдаңыз';

  @override
  String get coRxNone => 'Мақұлданған рецепт жоқ. Рецептті жүктеп, фармацевт тексеруін күтіңіз.';

  @override
  String get coRxUpload => 'Рецепт жүктеу';

  @override
  String coRxLine(String date) {
    return '$date рецепті';
  }

  @override
  String get coConsent => 'Құпиялылық саясатымен және пайдалану шарттарымен келісемін';

  @override
  String get coConsentRequired => 'Тапсырыс беру үшін келісім қажет';

  @override
  String coPlaceOrder(String total) {
    return 'Тапсырыс беру · $total';
  }

  @override
  String get coPlacing => 'Рәсімделуде…';

  @override
  String get coSummary => 'Сіздің тапсырысыңыз';

  @override
  String get coPriceChangedTitle => 'Бағалар өзгерді';

  @override
  String get coPriceChangedBody => 'Тапсырыс беру кезінде бағалар немесе қолжетімділік өзгерді. Себетті тексеріп, қайталаңыз.';

  @override
  String get coDoneTitle => 'Тапсырыс рәсімделді';

  @override
  String coDoneBody(String number) {
    return 'Тапсырыс нөмірі: $number';
  }

  @override
  String get coDoneDemo => 'Демо-тапсырыс: шынайы төлем мен жеткізу орындалмайды';

  @override
  String get coViewOrder => 'Тапсырысты бақылау';

  @override
  String get coBackHome => 'Басты бетке';

  @override
  String get coLoginRequired => 'Тапсырыс беру үшін кіріңіз';

  @override
  String get errPrescriptionRequired => 'Бұл тауарларға мақұлданған рецепт қажет';

  @override
  String get errPrescriptionNotApproved => 'Рецепт әлі мақұлданбаған немесе мерзімі өткен';

  @override
  String get errPrescriptionUsed => 'Бұл рецепт басқа тапсырыста қолданылған';

  @override
  String get errInsufficientStock => 'Қолда тауар жеткіліксіз';

  @override
  String get errOfferUnavailable => 'Тауарлардың бірі енді қолжетімсіз';

  @override
  String get errMixedBranches => 'Тауарлар бір дәріханадан болуы керек';

  @override
  String get errDeliveryUnavailable => 'Бұл дәріхана жеткізбейді';

  @override
  String get errSlotInvalid => 'Таңдалған жеткізу уақыты енді қолжетімсіз';

  @override
  String get errAddressRequired => 'Жеткізу мекенжайын көрсетіңіз';

  @override
  String get errPaymentUnavailable => 'Онлайн төлем қолжетімсіз. Алған кезде төлемді таңдаңыз.';

  @override
  String get errPaymentFailed => 'Төлем қабылданбады';

  @override
  String get errPhoneInvalid => 'Нөмірді +7 XXX XXX XX XX форматында енгізіңіз';

  @override
  String get errCancelNotAllowed => 'Тапсырысты енді бас тартуға болмайды';

  @override
  String get ordersTitle => 'Менің тапсырыстарым';

  @override
  String get ordersActive => 'Ағымдағы';

  @override
  String get ordersHistory => 'Тарих';

  @override
  String get ordersEmptyActive => 'Ағымдағы тапсырыс жоқ';

  @override
  String get ordersEmptyHistory => 'Тапсырыс тарихы бос';

  @override
  String get ordersGuestTitle => 'Тапсырыстарды көру үшін кіріңіз';

  @override
  String get ordersGuestBody => 'Мұнда тапсырыстарыңыз бен олардың мәртебесі көрсетіледі';

  @override
  String orderNumber(String number) {
    return '№ $number тапсырыс';
  }

  @override
  String get orderDetails => 'Тапсырыс мәліметтері';

  @override
  String get orderDelivery => 'Жеткізу';

  @override
  String get orderTracking => 'Бақылау';

  @override
  String get statusPlaced => 'Тапсырыс рәсімделді';

  @override
  String get statusConfirmed => 'Расталды';

  @override
  String get statusPreparing => 'Жиналуда';

  @override
  String get statusReadyForPickup => 'Беруге дайын';

  @override
  String get statusInTransit => 'Жолда';

  @override
  String get statusDelivered => 'Жеткізілді';

  @override
  String get statusDeliveredPickup => 'Берілді';

  @override
  String get statusCancelled => 'Бас тартылды';

  @override
  String get statusInTransitHint => 'Курьер сізге бет алды';

  @override
  String get statusPreparingHint => 'Дәріхана тапсырысыңызды жинауда';

  @override
  String get orderWindow => 'Жеткізу уақыты';

  @override
  String orderEtaEstimate(String from, String to) {
    return 'Шамамен $from–$to';
  }

  @override
  String get orderAddress => 'Жеткізу мекенжайы';

  @override
  String get orderPickupAddress => 'Беру орны';

  @override
  String get orderCourier => 'Курьер';

  @override
  String get orderCourierDemo => 'Демо-курьер (ойдан шығарылған)';

  @override
  String get orderCall => 'Қоңырау шалу';

  @override
  String get orderNoCourier => 'Курьер жөнелтер алдында тағайындалады';

  @override
  String get orderItems => 'Тапсырыс құрамы';

  @override
  String get orderSupport => 'Қолдау';

  @override
  String get orderSupportBody => 'Тапсырыс бойынша көмек керек пе? Дәріханаға немесе қолдау қызметіне хабарласыңыз.';

  @override
  String get orderContactPharmacy => 'Дәріханамен байланысу';

  @override
  String get orderCancel => 'Тапсырыстан бас тарту';

  @override
  String get orderCancelConfirm => 'Тапсырыстан бас тарту керек пе? Тауарлар қоймаға қайтарылады.';

  @override
  String get orderCancelled => 'Тапсырыс бас тартылды';

  @override
  String get orderReceipt => 'Түбіртек';

  @override
  String get orderReceiptNotice => 'Бұл тапсырыс туралы анықтама, фискалдық чек емес.';

  @override
  String get orderReorder => 'Тапсырысты қайталау';

  @override
  String orderReorderDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'Себетке $added тауар қосылды',
      one: 'Себетке $added тауар қосылды',
    );
    return '$_temp0';
  }

  @override
  String orderReorderSkipped(int count) {
    return 'Кейбір тауарлар қолжетімсіз, қосылмады: $count';
  }

  @override
  String get orderReorderChanged => 'Бағалар немесе саны өзгерді — себетті тексеріңіз';

  @override
  String get orderHistoryTitle => 'Мәртебелер тарихы';

  @override
  String get payUnpaid => 'Алған кезде төлем';

  @override
  String get payPending => 'Төлем күтілуде';

  @override
  String get payPaid => 'Төленді';

  @override
  String get payDemoPaid => 'Демо-төлем (ақша есептен шығарылмады)';

  @override
  String get payFailed => 'Төлем өтпеді';

  @override
  String get payRefundPending => 'Қайтару өңделуде';

  @override
  String get payRefunded => 'Қайтарылды';

  @override
  String get orderPayment => 'Төлем';

  @override
  String get orderFulfillmentDelivery => 'Жеткізу';

  @override
  String get orderFulfillmentPickup => 'Өзі алып кету';

  @override
  String get orderSimulatedNote => 'Демо-тапсырыс мәртебелері көрсету үшін автоматты түрде өзгереді. Нақты курьер мен GPS қосылмаған.';

  @override
  String get rxTitle => 'Рецепттер';

  @override
  String get rxUploadTitle => 'Рецепт жүктеу';

  @override
  String rxUploadHint(int size) {
    return 'Фото және PDF (JPG, PNG, PDF) қолдау көрсетіледі, $size МБ дейін';
  }

  @override
  String get rxLegal => 'Рецептті фармацевт тексереді. Файлды жүктеу мақұлдауды білдірмейді.';

  @override
  String get rxTakePhoto => 'Суретке түсіру';

  @override
  String get rxGallery => 'Галереядан';

  @override
  String get rxPdf => 'PDF таңдау';

  @override
  String get rxAddMore => 'Тағы қосу';

  @override
  String get rxNote => 'Пікір (міндетті емес)';

  @override
  String get rxSubmit => 'Тексеруге жіберу';

  @override
  String rxUploading(int percent) {
    return 'Жүктелуде $percent%';
  }

  @override
  String get rxSubmittedOk => 'Рецепт тексеруге жіберілді';

  @override
  String get rxStatusDraft => 'Жоба';

  @override
  String get rxStatusSubmitted => 'Жіберілді';

  @override
  String get rxStatusUnderReview => 'Тексерілуде';

  @override
  String get rxStatusApproved => 'Мақұлданды';

  @override
  String get rxStatusRejected => 'Қабылданбады';

  @override
  String get rxStatusExpired => 'Мерзімі өтті';

  @override
  String rxRejectionReason(String reason) {
    return 'Бас тарту себебі: $reason';
  }

  @override
  String rxValidUntil(String date) {
    return '$date дейін жарамды';
  }

  @override
  String get rxHistory => 'Менің рецепттерім';

  @override
  String get rxEmpty => 'Сіз әлі рецепт жүктемегенсіз';

  @override
  String rxFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count файл', one: '$count файл');
    return '$_temp0';
  }

  @override
  String rxTooLarge(int size) {
    return 'Файл $size МБ-тан үлкен';
  }

  @override
  String get rxBadType => 'Тек JPG, PNG және PDF рұқсат етіледі';

  @override
  String rxMaxFiles(int count) {
    return '$count файлдан артық емес';
  }

  @override
  String get rxNoFiles => 'Кемінде бір файл қосыңыз';

  @override
  String get rxDemoReview => 'Демо-тексеру: бұл нағыз фармацевттің тексеруі емес';

  @override
  String get rxTimeline => 'Тексеру барысы';

  @override
  String get rxEventCreated => 'Жоба жасалды';

  @override
  String get rxEventSubmitted => 'Тексеруге жіберілді';

  @override
  String get rxEventReviewStarted => 'Тексеру басталды';

  @override
  String get rxEventApproved => 'Рецепт мақұлданды';

  @override
  String get rxEventRejected => 'Рецепт қабылданбады';

  @override
  String get rxEventExpired => 'Жарамдылық мерзімі өтті';

  @override
  String get rxUsable => 'Тапсырыста қолдануға болады';

  @override
  String get rxDeleteDraft => 'Жобаны жою';

  @override
  String get rxLoginRequired => 'Рецептті жүктеу үшін кіріңіз';

  @override
  String get rxFileRemove => 'Файлды алып тастау';

  @override
  String get rxNewShort => 'Жаңа рецепт';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginSubtitle => 'Телефон нөмірі арқылы кіріңіз';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get registerSubtitle => 'Нөміріңізді код арқылы растаймыз';

  @override
  String get authPhone => 'Телефон нөмірі';

  @override
  String get authPassword => 'Құпиясөз';

  @override
  String get authPasswordHint => 'Кемінде 8 таңба, әріптер мен сандар';

  @override
  String get authFullName => 'Аты-жөні';

  @override
  String get authConsent => 'Құпиялылық саясатын қабылдаймын және жеке деректерді өңдеуге келісемін';

  @override
  String get authConsentRequired => 'Деректерді өңдеуге келісім қажет';

  @override
  String get authLoginAction => 'Кіру';

  @override
  String get authRegisterAction => 'Тіркелу';

  @override
  String get authNoAccount => 'Аккаунт жоқ па? Тіркеліңіз';

  @override
  String get authHaveAccount => 'Аккаунтыңыз бар ма? Кіріңіз';

  @override
  String get authContinueGuest => 'Кірместен жалғастыру';

  @override
  String get otpTitle => 'Нөмірді растау';

  @override
  String otpBody(String phone) {
    return '$phone нөміріне жіберілген кодты енгізіңіз';
  }

  @override
  String otpDemoNote(String code) {
    return 'ДЕМО: код $code. Жұмыс режимінде код SMS арқылы келеді.';
  }

  @override
  String get otpResend => 'Кодты қайта жіберу';

  @override
  String otpResendIn(int seconds) {
    return '$seconds с кейін қайта жіберу';
  }

  @override
  String get otpVerify => 'Растау';

  @override
  String get otpCode => 'SMS-тегі код';

  @override
  String get errInvalidCredentials => 'Телефон немесе құпиясөз қате';

  @override
  String get errPhoneNotVerified => 'Нөмір расталмаған. Тіркеуді аяқтаңыз.';

  @override
  String get errPhoneExists => 'Бұл нөмір тіркелген';

  @override
  String get errWeakPassword => 'Құпиясөзде әріптер мен сандар болуы керек (8 таңбадан)';

  @override
  String get errOtpInvalid => 'Код қате немесе мерзімі өткен';

  @override
  String get errOtpTooSoon => 'Код жіберілді. Біраз күтіңіз.';

  @override
  String get errOtpUnavailable => 'SMS растау қызметі қазір қолжетімсіз';

  @override
  String get errAccountDisabled => 'Аккаунт өшірілген';

  @override
  String get passwordShow => 'Құпиясөзді көрсету';

  @override
  String get passwordHide => 'Құпиясөзді жасыру';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileGuestTitle => 'DARMAN-ға қош келдіңіз';

  @override
  String get profileGuestBody => 'Тапсырыс беру, мекенжайлар мен рецепттерді сақтау үшін кіріңіз';

  @override
  String get profileLoginRegister => 'Кіру немесе тіркелу';

  @override
  String get profileMyOrders => 'Менің тапсырыстарым';

  @override
  String get profileRx => 'Рецепттер';

  @override
  String get profileAddresses => 'Жеткізу мекенжайлары';

  @override
  String get profileFavorites => 'Таңдаулылар';

  @override
  String get profileNotifications => 'Хабарландырулар';

  @override
  String get profileLanguage => 'Тіл';

  @override
  String get profilePrivacy => 'Құпиялылық саясаты';

  @override
  String get profileTerms => 'Пайдалану шарттары';

  @override
  String get profileHelp => 'Көмек және қолдау';

  @override
  String get profileLogout => 'Шығу';

  @override
  String get profileLogoutConfirm => 'Аккаунттан шығу керек пе?';

  @override
  String get profileDelete => 'Аккаунтты жою';

  @override
  String get profileDeleteBody =>
      'Біз аккаунт пен жеке деректерді жою сұранысын қабылдаймыз. Заң бойынша сақталуы тиіс тапсырыстар иесіздендірілген түрде қалуы мүмкін. Сұранысты болдырмауға болады.';

  @override
  String get profileDeleteRequested => 'Жою сұранысы жіберілді';

  @override
  String get profileDeletePending => 'Аккаунтты жою сұралды';

  @override
  String get profileDeleteCancel => 'Жою сұранысын болдырмау';

  @override
  String get profileEdit => 'Жеке деректер';

  @override
  String get profileFullName => 'Аты-жөні';

  @override
  String get profileEmail => 'Электрондық пошта';

  @override
  String get profileEmailInvalid => 'Email қате';

  @override
  String get profileSaved => 'Сақталды';

  @override
  String get notifSettings => 'Хабарландыру баптаулары';

  @override
  String get notifOrders => 'Тапсырыс мәртебелері';

  @override
  String get notifPrescriptions => 'Рецепттерді тексеру';

  @override
  String get notifPromotions => 'Акциялар мен ұсыныстар';

  @override
  String get notifInbox => 'Хабарландырулар орталығы';

  @override
  String get notifEmpty => 'Хабарландыру әзірге жоқ';

  @override
  String get notifRxApproved => 'Рецепт мақұлданды';

  @override
  String get notifRxRejected => 'Рецепт қабылданбады';

  @override
  String get notifRxReview => 'Рецепт тексерілуде';

  @override
  String get notifOrderPlaced => 'Тапсырыс рәсімделді';

  @override
  String get notifOrderUpdate => 'Тапсырыс мәртебесі өзгерді';

  @override
  String get notifOrderCancelled => 'Тапсырыс бас тартылды';

  @override
  String appVersion(String version) {
    return 'Нұсқа $version';
  }

  @override
  String get languageTitle => 'Қолданба тілі';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get languageEn => 'English';

  @override
  String get favoritesTitle => 'Таңдаулылар';

  @override
  String get favoritesEmpty => 'Таңдаулыларда әзірге ештеңе жоқ';

  @override
  String get favoritesEmptyBody => 'Тауарды сақтау үшін жүрекшені басыңыз';

  @override
  String get favoritesGuestNote => 'Таңдаулылар құрылғыда сақталады. Аккаунтқа сақтау үшін кіріңіз.';

  @override
  String get addressesTitle => 'Жеткізу мекенжайлары';

  @override
  String get addressesEmpty => 'Мекенжай әзірге жоқ';

  @override
  String get addressAdd => 'Мекенжай қосу';

  @override
  String get addressEdit => 'Мекенжайды өзгерту';

  @override
  String get addressLabel => 'Атауы (Үй, Жұмыс…)';

  @override
  String get addressCity => 'Қала';

  @override
  String get addressStreet => 'Көше';

  @override
  String get addressHouse => 'Үй';

  @override
  String get addressApartment => 'Пәтер';

  @override
  String get addressEntrance => 'Кіреберіс';

  @override
  String get addressFloor => 'Қабат';

  @override
  String get addressComment => 'Пікір';

  @override
  String get addressDefault => 'Негізгі мекенжай';

  @override
  String get addressDefaultBadge => 'Негізгі';

  @override
  String get addressDeleteConfirm => 'Бұл мекенжайды жою керек пе?';

  @override
  String get pharmaciesTitle => 'Дәріханалар';

  @override
  String pharmacyHours(String hours) {
    return 'Жұмыс уақыты: $hours';
  }

  @override
  String pharmacyDistance(String km) {
    return '$km км';
  }

  @override
  String get pharmacyDelivers => 'Жеткізу бар';

  @override
  String get pharmacyPickupOnly => 'Тек өзі алып кету';

  @override
  String get pharmacyCall => 'Дәріханаға қоңырау шалу';

  @override
  String get pharmacyProducts => 'Дәріхана тауарлары';

  @override
  String get legalDraftNote => 'Мәтін жобасы. Іске қосар алдында заңгер мен салалық мамандар тексеруі керек.';

  @override
  String get privacyBody =>
      'DARMAN телефон нөмірін, атын, жеткізу мекенжайларын, тапсырыс тарихын және қалауыңыз бойынша рецепт суреттерін тек тапсырыстарды рәсімдеу мен орындау, рецептті фармацевтпен тексеру және қолдау үшін өңдейді. Рецепт файлдары жабық қоймада сақталады, оларға сіз және уәкілетті фармацевт қол жеткізе алады, әр қатынас тіркеледі. «Профиль» бөлімінде аккаунт пен деректерді жоюды кез келген уақытта сұрауға болады. Біз жеке деректерді сатпаймыз.';

  @override
  String get termsBody =>
      'DARMAN — серіктес дәріханалардағы тауарларды іздеуге және тапсырыс беруге арналған сервис. Рецепт бойынша тауарлар рецептті фармацевт тексергеннен кейін ғана беріледі. Қосымшадағы ақпарат анықтамалық сипатта және маман кеңесін алмастырмайды. Қолжетімділік, баға және жеткізу мерзімін дәріхана анықтайды; көрсетілген жеткізу уақыты шамамен алынған. Дәріхана жинауды бастағанға дейін тапсырыстан бас тартуға болады.';

  @override
  String get helpTitle => 'Көмек және қолдау';

  @override
  String get helpFaqRxQ => 'Рецепт бойынша дәріні қалай тапсырыс беруге болады?';

  @override
  String get helpFaqRxA =>
      '«Рецепттер» бөлімінде рецепт суретін жүктеңіз. Фармацевт мақұлдағаннан кейін оны тапсырыс беру кезінде таңдаңыз.';

  @override
  String get helpFaqDeliveryQ => 'Жеткізу қалай жұмыс істейді?';

  @override
  String get helpFaqDeliveryA =>
      'Тапсырысты бір дәріхана орындайды. Жеткізу уақыты шамамен; мәртебе жиналып, курьерге берілген сайын жаңарады.';

  @override
  String get helpFaqPayQ => 'Тапсырысты қалай төлеуге болады?';

  @override
  String get helpFaqPayA =>
      'Алған кезде төлеуге болады. Онлайн карта төлемі төлем провайдері қосылғаннан кейін қолжетімді болады; демо-режимде ақша есептен шығарылмайды.';

  @override
  String get helpContact => 'Қолдау қызметімен байланысу';

  @override
  String get helpNoPhone => 'Қолдау байланыстары әлі бапталмаған';

  @override
  String get helpEmergency => 'Өмірге қауіп төнсе, дереу 103-ке қоңырау шалыңыз.';

  @override
  String get themeTitle => 'Көрініс';

  @override
  String get themeLight => 'Жарық';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get themeSystem => 'Жүйедегідей';
}
