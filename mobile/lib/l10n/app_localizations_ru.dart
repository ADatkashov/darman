// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'DARMAN';

  @override
  String get slogan => 'Здоровье рядом';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get close => 'Закрыть';

  @override
  String get ok => 'Понятно';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get back => 'Назад';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get seeAll => 'Смотреть все';

  @override
  String get add => 'Добавить';

  @override
  String get remove => 'Убрать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get free => 'Бесплатно';

  @override
  String get demoBadge => 'ДЕМО';

  @override
  String get clear => 'Очистить';

  @override
  String get optional => 'необязательно';

  @override
  String get required => 'Обязательное поле';

  @override
  String get currencySymbol => '₸';

  @override
  String get offlineBanner => 'Нет подключения к интернету';

  @override
  String get errNetwork => 'Не удаётся подключиться к серверу. Проверьте интернет и повторите.';

  @override
  String get errServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errUnknown => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errNotFound => 'Не найдено';

  @override
  String get errForbidden => 'Недостаточно прав';

  @override
  String get errRateLimited => 'Слишком много запросов. Подождите минуту.';

  @override
  String get errValidation => 'Проверьте введённые данные';

  @override
  String get errSessionExpired => 'Сессия истекла. Войдите снова.';

  @override
  String get medicalDisclaimer =>
      'Информация в приложении не заменяет консультацию врача или фармацевта. Перед применением изучите инструкцию и проконсультируйтесь со специалистом.';

  @override
  String get demoDataNote => 'Демонстрационные данные: товары и аптеки вымышлены.';

  @override
  String get demoModeBanner => 'Демо-режим: данные вымышлены, оплата и доставка не настоящие';

  @override
  String get navHome => 'Главная';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navCart => 'Корзина';

  @override
  String get navOrders => 'Заказы';

  @override
  String get navProfile => 'Профиль';

  @override
  String get onb1Title => 'Найдите нужное лекарство';

  @override
  String get onb1Body => 'Ищите по названию, действующему веществу, бренду или дозировке.';

  @override
  String get onb2Title => 'Сравнивайте цены аптек';

  @override
  String get onb2Body => 'Смотрите предложения разных аптек, наличие и условия доставки.';

  @override
  String get onb3Title => 'Рецепт — через фармацевта';

  @override
  String get onb3Body => 'Загрузите фото рецепта: его проверит фармацевт, где это предусмотрено законом.';

  @override
  String get onb4Title => 'Доставка и отслеживание';

  @override
  String get onb4Body => 'Следите за статусом заказа от подтверждения до получения.';

  @override
  String get homeSearchHint => 'Поиск лекарств и товаров';

  @override
  String get homeCategories => 'Категории';

  @override
  String get homePopular => 'Популярные товары';

  @override
  String get homeFrequent => 'Часто покупают';

  @override
  String get homeOffers => 'Акции и скидки';

  @override
  String get homeNearby => 'Аптеки рядом';

  @override
  String get homeRecent => 'Вы смотрели';

  @override
  String get homeRxTitle => 'Есть рецепт?';

  @override
  String get homeRxBody => 'Загрузите фото — фармацевт проверит рецепт';

  @override
  String get homeRxAction => 'Загрузить рецепт';

  @override
  String homeDeliveryInfo(int min, int max) {
    return 'Доставка по Алматы · ориентировочно $min–$max мин';
  }

  @override
  String get homeCity => 'Город';

  @override
  String get homeCitySoon => 'Другие города скоро появятся';

  @override
  String promoCodeBanner(String code) {
    return 'Промокод $code';
  }

  @override
  String get emptySection => 'Пока ничего нет';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchHint => 'Название, вещество, бренд…';

  @override
  String get searchRecent => 'Недавние запросы';

  @override
  String get searchClearHistory => 'Очистить историю';

  @override
  String get searchSuggestions => 'Подсказки';

  @override
  String searchFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count товара',
      many: 'Найдено $count товаров',
      few: 'Найдено $count товара',
      one: 'Найден $count товар',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResultsTitle => 'Ничего не найдено';

  @override
  String get searchNoResultsBody =>
      'Проверьте написание или поищите по действующему веществу. Мы не подставляем похожие, но другие товары.';

  @override
  String get searchBrowseCategories => 'Посмотреть категории';

  @override
  String get sortLabel => 'Сортировка';

  @override
  String get sortRelevance => 'По релевантности';

  @override
  String get sortPriceAsc => 'Сначала дешёвые';

  @override
  String get sortPriceDesc => 'Сначала дорогие';

  @override
  String get sortPopularity => 'По популярности';

  @override
  String get filters => 'Фильтры';

  @override
  String get filterCategory => 'Категория';

  @override
  String get filterManufacturer => 'Производитель';

  @override
  String get filterAll => 'Все';

  @override
  String get filterInStock => 'Только в наличии';

  @override
  String get filterPrice => 'Цена, ₸';

  @override
  String get filterPriceFrom => 'От';

  @override
  String get filterPriceTo => 'До';

  @override
  String get filterRx => 'Рецептурные';

  @override
  String get filterRxAny => 'Любые';

  @override
  String get filterRxOnly => 'Только по рецепту';

  @override
  String get filterRxNone => 'Без рецепта';

  @override
  String get loadMore => 'Загрузить ещё';

  @override
  String get searchClearSemantic => 'Очистить поиск';

  @override
  String get productTitle => 'Товар';

  @override
  String get prodBrand => 'Бренд';

  @override
  String get prodIngredient => 'Действующее вещество';

  @override
  String get prodStrength => 'Дозировка';

  @override
  String get prodForm => 'Форма выпуска';

  @override
  String get prodPackage => 'Упаковка';

  @override
  String get prodManufacturer => 'Производитель';

  @override
  String get prodDescription => 'Описание';

  @override
  String get prodUsage => 'Способ применения';

  @override
  String get prodStorage => 'Условия хранения';

  @override
  String get prodWarnings => 'Предупреждения';

  @override
  String get prodContraindications => 'Противопоказания';

  @override
  String get prodComposition => 'Состав';

  @override
  String get prodInfoUnavailable =>
      'Официальная инструкция недоступна. Изучите инструкцию в упаковке и проконсультируйтесь со специалистом.';

  @override
  String prodInfoSource(String source) {
    return 'Источник: $source';
  }

  @override
  String get badgeRx => 'По рецепту';

  @override
  String get badgeOtc => 'Без рецепта';

  @override
  String get rxNeededNote => 'Для заказа нужен одобренный фармацевтом рецепт.';

  @override
  String get offersTitle => 'Предложения аптек';

  @override
  String get offersBestPrice => 'Лучшая цена';

  @override
  String get offersNone => 'Сейчас нет предложений в вашем городе';

  @override
  String get offerPickup => 'Самовывоз';

  @override
  String get offerDelivery => 'Доставка';

  @override
  String get offerNoDelivery => 'Без доставки';

  @override
  String offerDeliveryFee(String fee) {
    return 'Доставка $fee';
  }

  @override
  String offerFreeFrom(String amount) {
    return 'бесплатно от $amount';
  }

  @override
  String offerEta(int min, int max) {
    return '≈ $min–$max мин (оценка)';
  }

  @override
  String offerUpdated(String time) {
    return 'Обновлено $time';
  }

  @override
  String get stockIn => 'В наличии';

  @override
  String get stockLow => 'Мало';

  @override
  String get stockOut => 'Нет в наличии';

  @override
  String stockCount(int count) {
    return 'В наличии: $count шт.';
  }

  @override
  String get addToCart => 'В корзину';

  @override
  String get addedToCart => 'Добавлено в корзину';

  @override
  String get viewCart => 'Открыть';

  @override
  String get favoriteAdd => 'Добавить в избранное';

  @override
  String get favoriteRemove => 'Убрать из избранного';

  @override
  String get selectOffer => 'Выбрать';

  @override
  String get offerSelected => 'Выбрано';

  @override
  String priceFrom(String price) {
    return 'от $price';
  }

  @override
  String get quantityDecrease => 'Уменьшить количество';

  @override
  String get quantityIncrease => 'Увеличить количество';

  @override
  String quantityLabel(int count) {
    return 'Количество: $count';
  }

  @override
  String get unavailableOffer => 'Предложение недоступно';

  @override
  String get pharmacyDemoNote => 'Вымышленная аптека (демо)';

  @override
  String get licenseNotVerified => 'Лицензия не проверена (демо-данные)';

  @override
  String get cartTitle => 'Корзина';

  @override
  String get cartEmptyTitle => 'В корзине пока пусто';

  @override
  String get cartEmptyBody => 'Найдите нужные товары в каталоге и добавьте их в корзину';

  @override
  String get goToCatalog => 'Перейти в каталог';

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товара',
      many: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$_temp0';
  }

  @override
  String cartPharmacy(String name) {
    return 'Аптека: $name';
  }

  @override
  String get cartPromo => 'Промокод';

  @override
  String get cartPromoHint => 'Введите промокод';

  @override
  String cartPromoApplied(String amount) {
    return 'Промокод применён: −$amount';
  }

  @override
  String get cartPromoInvalid => 'Промокод не подходит';

  @override
  String get cartPromoMin => 'Минимальная сумма заказа для промокода не достигнута';

  @override
  String get cartSubtotal => 'Товары';

  @override
  String get cartDelivery => 'Доставка';

  @override
  String get cartDiscount => 'Скидка';

  @override
  String get cartTotal => 'Итого';

  @override
  String get cartCheckout => 'Оформить заказ';

  @override
  String get cartClear => 'Очистить корзину';

  @override
  String get cartClearConfirm => 'Удалить все товары из корзины?';

  @override
  String get cartBranchMismatchTitle => 'Товары из другой аптеки';

  @override
  String cartBranchMismatchBody(String name) {
    return 'Заказ выполняет одна аптека. В корзине уже есть товары из «$name». Заменить корзину?';
  }

  @override
  String get cartReplace => 'Заменить';

  @override
  String get cartKeep => 'Оставить';

  @override
  String cartIssuePrice(String old, String now) {
    return 'Цена изменилась: было $old, стало $now';
  }

  @override
  String get cartIssueOut => 'Нет в наличии';

  @override
  String cartIssueLow(int count) {
    return 'Доступно только $count шт.';
  }

  @override
  String get cartIssueUnavailable => 'Предложение больше недоступно';

  @override
  String get cartFixIssues => 'Уберите недоступные товары или измените количество';

  @override
  String get cartCheckFailed => 'Не удалось проверить наличие и цены. Они будут перепроверены при оформлении.';

  @override
  String get cartRxNeeded => 'В корзине есть рецептурные товары — для заказа нужен одобренный рецепт';

  @override
  String cartFreeDeliveryFrom(String amount) {
    return 'Бесплатная доставка от $amount';
  }

  @override
  String get cartDeliveryUnavailable => 'Эта аптека не доставляет — доступен самовывоз';

  @override
  String cartRemoveItem(String name) {
    return 'Удалить $name из корзины';
  }

  @override
  String get checkoutTitle => 'Оформление заказа';

  @override
  String get coContact => 'Контакты';

  @override
  String get coName => 'Имя получателя';

  @override
  String get coPhone => 'Телефон';

  @override
  String get coFulfillment => 'Способ получения';

  @override
  String get coDelivery => 'Доставка';

  @override
  String get coPickup => 'Самовывоз';

  @override
  String coPickupFrom(String address) {
    return 'Заберите в аптеке: $address';
  }

  @override
  String get coAddress => 'Адрес доставки';

  @override
  String get coChooseAddress => 'Выберите адрес';

  @override
  String get coAddAddress => 'Добавить адрес';

  @override
  String get coNotes => 'Комментарий для курьера';

  @override
  String get coSlot => 'Время доставки';

  @override
  String coAsap(int min, int max) {
    return 'Как можно скорее · ≈ $min–$max мин (оценка)';
  }

  @override
  String get coSlotToday => 'Сегодня';

  @override
  String get coSlotTomorrow => 'Завтра';

  @override
  String get coPayment => 'Оплата';

  @override
  String get coPayCash => 'Наличными при получении';

  @override
  String get coPayCard => 'Банковской картой онлайн';

  @override
  String get coPayCardDemo => 'Картой онлайн — ДЕМО (деньги не списываются)';

  @override
  String get coPayCardUnavailable => 'Онлайн-оплата сейчас недоступна';

  @override
  String get coRxSection => 'Рецепт';

  @override
  String get coRxChoose => 'Выберите одобренный рецепт';

  @override
  String get coRxNone => 'Нет одобренных рецептов. Загрузите рецепт и дождитесь проверки фармацевтом.';

  @override
  String get coRxUpload => 'Загрузить рецепт';

  @override
  String coRxLine(String date) {
    return 'Рецепт от $date';
  }

  @override
  String get coConsent => 'Я согласен(на) с Политикой конфиденциальности и Условиями использования';

  @override
  String get coConsentRequired => 'Необходимо согласие для оформления заказа';

  @override
  String coPlaceOrder(String total) {
    return 'Оформить заказ · $total';
  }

  @override
  String get coPlacing => 'Оформляем…';

  @override
  String get coSummary => 'Ваш заказ';

  @override
  String get coPriceChangedTitle => 'Цены изменились';

  @override
  String get coPriceChangedBody => 'Пока вы оформляли заказ, цены или наличие изменились. Проверьте корзину и повторите.';

  @override
  String get coDoneTitle => 'Заказ оформлен';

  @override
  String coDoneBody(String number) {
    return 'Номер заказа: $number';
  }

  @override
  String get coDoneDemo => 'Демо-заказ: настоящая оплата и доставка не выполняются';

  @override
  String get coViewOrder => 'Следить за заказом';

  @override
  String get coBackHome => 'На главную';

  @override
  String get coLoginRequired => 'Войдите, чтобы оформить заказ';

  @override
  String get errPrescriptionRequired => 'Для этих товаров нужен одобренный рецепт';

  @override
  String get errPrescriptionNotApproved => 'Рецепт ещё не одобрен или срок его действия истёк';

  @override
  String get errPrescriptionUsed => 'Этот рецепт уже использован в другом заказе';

  @override
  String get errInsufficientStock => 'Недостаточно товара в наличии';

  @override
  String get errOfferUnavailable => 'Один из товаров больше недоступен';

  @override
  String get errMixedBranches => 'Товары должны быть из одной аптеки';

  @override
  String get errDeliveryUnavailable => 'Эта аптека не доставляет';

  @override
  String get errSlotInvalid => 'Выбранное время доставки больше недоступно';

  @override
  String get errAddressRequired => 'Укажите адрес доставки';

  @override
  String get errPaymentUnavailable => 'Онлайн-оплата недоступна. Выберите оплату при получении.';

  @override
  String get errPaymentFailed => 'Платёж отклонён';

  @override
  String get errPhoneInvalid => 'Введите номер в формате +7 XXX XXX XX XX';

  @override
  String get errCancelNotAllowed => 'Заказ уже нельзя отменить';

  @override
  String get ordersTitle => 'Мои заказы';

  @override
  String get ordersActive => 'Текущие';

  @override
  String get ordersHistory => 'История';

  @override
  String get ordersEmptyActive => 'Нет текущих заказов';

  @override
  String get ordersEmptyHistory => 'История заказов пуста';

  @override
  String get ordersGuestTitle => 'Войдите, чтобы видеть заказы';

  @override
  String get ordersGuestBody => 'Здесь появятся ваши заказы и их статусы';

  @override
  String orderNumber(String number) {
    return 'Заказ № $number';
  }

  @override
  String get orderDetails => 'Детали заказа';

  @override
  String get orderDelivery => 'Доставка';

  @override
  String get orderTracking => 'Отслеживание';

  @override
  String get statusPlaced => 'Заказ оформлен';

  @override
  String get statusConfirmed => 'Подтверждён';

  @override
  String get statusPreparing => 'Собирается';

  @override
  String get statusReadyForPickup => 'Готов к выдаче';

  @override
  String get statusInTransit => 'В пути';

  @override
  String get statusDelivered => 'Доставлен';

  @override
  String get statusDeliveredPickup => 'Выдан';

  @override
  String get statusCancelled => 'Отменён';

  @override
  String get statusInTransitHint => 'Курьер направляется к вам';

  @override
  String get statusPreparingHint => 'Аптека собирает ваш заказ';

  @override
  String get orderWindow => 'Окно доставки';

  @override
  String orderEtaEstimate(String from, String to) {
    return 'Ориентировочно $from–$to';
  }

  @override
  String get orderAddress => 'Адрес доставки';

  @override
  String get orderPickupAddress => 'Пункт выдачи';

  @override
  String get orderCourier => 'Курьер';

  @override
  String get orderCourierDemo => 'Демо-курьер (вымышленный)';

  @override
  String get orderCall => 'Позвонить';

  @override
  String get orderNoCourier => 'Курьер будет назначен перед отправкой';

  @override
  String get orderItems => 'Состав заказа';

  @override
  String get orderSupport => 'Поддержка';

  @override
  String get orderSupportBody => 'Нужна помощь с заказом? Свяжитесь с аптекой или поддержкой.';

  @override
  String get orderContactPharmacy => 'Связаться с аптекой';

  @override
  String get orderCancel => 'Отменить заказ';

  @override
  String get orderCancelConfirm => 'Отменить этот заказ? Товары вернутся на склад.';

  @override
  String get orderCancelled => 'Заказ отменён';

  @override
  String get orderReceipt => 'Квитанция';

  @override
  String get orderReceiptNotice => 'Это справка о заказе, а не фискальный чек.';

  @override
  String get orderReorder => 'Повторить заказ';

  @override
  String orderReorderDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'Добавлено $added товара',
      many: 'Добавлено $added товаров',
      few: 'Добавлено $added товара',
      one: 'Добавлен $added товар',
    );
    return '$_temp0 в корзину';
  }

  @override
  String orderReorderSkipped(int count) {
    return 'Часть товаров недоступна и не добавлена: $count';
  }

  @override
  String get orderReorderChanged => 'Цены или количество изменились — проверьте корзину';

  @override
  String get orderHistoryTitle => 'История статусов';

  @override
  String get payUnpaid => 'Оплата при получении';

  @override
  String get payPending => 'Ожидает оплаты';

  @override
  String get payPaid => 'Оплачено';

  @override
  String get payDemoPaid => 'Демо-оплата (деньги не списаны)';

  @override
  String get payFailed => 'Платёж не прошёл';

  @override
  String get payRefundPending => 'Возврат в обработке';

  @override
  String get payRefunded => 'Возвращено';

  @override
  String get orderPayment => 'Оплата';

  @override
  String get orderFulfillmentDelivery => 'Доставка';

  @override
  String get orderFulfillmentPickup => 'Самовывоз';

  @override
  String get orderSimulatedNote => 'Статусы демо-заказов меняются автоматически для демонстрации. Реальный курьер и GPS не подключены.';

  @override
  String get rxTitle => 'Рецепты';

  @override
  String get rxUploadTitle => 'Загрузка рецепта';

  @override
  String rxUploadHint(int size) {
    return 'Поддерживаются фото и PDF (JPG, PNG, PDF) до $size МБ';
  }

  @override
  String get rxLegal => 'Рецепт проверяет фармацевт. Загрузка файла не означает одобрения.';

  @override
  String get rxTakePhoto => 'Сфотографировать';

  @override
  String get rxGallery => 'Из галереи';

  @override
  String get rxPdf => 'Выбрать PDF';

  @override
  String get rxAddMore => 'Добавить ещё';

  @override
  String get rxNote => 'Комментарий (необязательно)';

  @override
  String get rxSubmit => 'Отправить на проверку';

  @override
  String rxUploading(int percent) {
    return 'Загрузка $percent%';
  }

  @override
  String get rxSubmittedOk => 'Рецепт отправлен на проверку';

  @override
  String get rxStatusDraft => 'Черновик';

  @override
  String get rxStatusSubmitted => 'Отправлен';

  @override
  String get rxStatusUnderReview => 'На проверке';

  @override
  String get rxStatusApproved => 'Одобрен';

  @override
  String get rxStatusRejected => 'Отклонён';

  @override
  String get rxStatusExpired => 'Срок истёк';

  @override
  String rxRejectionReason(String reason) {
    return 'Причина отказа: $reason';
  }

  @override
  String rxValidUntil(String date) {
    return 'Действителен до $date';
  }

  @override
  String get rxHistory => 'Мои рецепты';

  @override
  String get rxEmpty => 'Вы ещё не загружали рецепты';

  @override
  String rxFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String rxTooLarge(int size) {
    return 'Файл больше $size МБ';
  }

  @override
  String get rxBadType => 'Допустимы только JPG, PNG и PDF';

  @override
  String rxMaxFiles(int count) {
    return 'Не более $count файлов';
  }

  @override
  String get rxNoFiles => 'Добавьте хотя бы один файл';

  @override
  String get rxDemoReview => 'Демо-проверка: это не проверка настоящим фармацевтом';

  @override
  String get rxTimeline => 'Ход проверки';

  @override
  String get rxEventCreated => 'Черновик создан';

  @override
  String get rxEventSubmitted => 'Отправлен на проверку';

  @override
  String get rxEventReviewStarted => 'Проверка началась';

  @override
  String get rxEventApproved => 'Рецепт одобрен';

  @override
  String get rxEventRejected => 'Рецепт отклонён';

  @override
  String get rxEventExpired => 'Срок действия истёк';

  @override
  String get rxUsable => 'Можно использовать в заказе';

  @override
  String get rxDeleteDraft => 'Удалить черновик';

  @override
  String get rxLoginRequired => 'Войдите, чтобы загрузить рецепт';

  @override
  String get rxFileRemove => 'Убрать файл';

  @override
  String get rxNewShort => 'Новый рецепт';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle => 'Войдите по номеру телефона';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Подтвердим номер по коду';

  @override
  String get authPhone => 'Номер телефона';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordHint => 'Не менее 8 символов, буквы и цифры';

  @override
  String get authFullName => 'Имя';

  @override
  String get authConsent => 'Я принимаю Политику конфиденциальности и согласен на обработку персональных данных';

  @override
  String get authConsentRequired => 'Необходимо согласие на обработку данных';

  @override
  String get authLoginAction => 'Войти';

  @override
  String get authRegisterAction => 'Зарегистрироваться';

  @override
  String get authNoAccount => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? Войдите';

  @override
  String get authContinueGuest => 'Продолжить без входа';

  @override
  String get otpTitle => 'Подтверждение номера';

  @override
  String otpBody(String phone) {
    return 'Введите код, отправленный на $phone';
  }

  @override
  String otpDemoNote(String code) {
    return 'ДЕМО: код $code. В рабочем режиме код приходит по SMS.';
  }

  @override
  String get otpResend => 'Отправить код ещё раз';

  @override
  String otpResendIn(int seconds) {
    return 'Повторно через $seconds с';
  }

  @override
  String get otpVerify => 'Подтвердить';

  @override
  String get otpCode => 'Код из SMS';

  @override
  String get errInvalidCredentials => 'Неверный телефон или пароль';

  @override
  String get errPhoneNotVerified => 'Номер не подтверждён. Завершите регистрацию.';

  @override
  String get errPhoneExists => 'Этот номер уже зарегистрирован';

  @override
  String get errWeakPassword => 'Пароль должен содержать буквы и цифры (от 8 символов)';

  @override
  String get errOtpInvalid => 'Неверный или просроченный код';

  @override
  String get errOtpTooSoon => 'Код уже отправлен. Подождите немного.';

  @override
  String get errOtpUnavailable => 'Сервис SMS-подтверждения сейчас недоступен';

  @override
  String get errAccountDisabled => 'Аккаунт отключён';

  @override
  String get passwordShow => 'Показать пароль';

  @override
  String get passwordHide => 'Скрыть пароль';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileGuestTitle => 'Добро пожаловать в DARMAN';

  @override
  String get profileGuestBody => 'Войдите, чтобы оформлять заказы, сохранять адреса и рецепты';

  @override
  String get profileLoginRegister => 'Войти или зарегистрироваться';

  @override
  String get profileMyOrders => 'Мои заказы';

  @override
  String get profileRx => 'Рецепты';

  @override
  String get profileAddresses => 'Адреса доставки';

  @override
  String get profileFavorites => 'Избранное';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profilePrivacy => 'Политика конфиденциальности';

  @override
  String get profileTerms => 'Условия использования';

  @override
  String get profileHelp => 'Помощь и поддержка';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileLogoutConfirm => 'Выйти из аккаунта?';

  @override
  String get profileDelete => 'Удалить аккаунт';

  @override
  String get profileDeleteBody =>
      'Мы примем запрос на удаление аккаунта и персональных данных. Заказы, которые нужно хранить по закону, могут сохраняться в обезличенном виде. Запрос можно отменить.';

  @override
  String get profileDeleteRequested => 'Запрос на удаление отправлен';

  @override
  String get profileDeletePending => 'Запрошено удаление аккаунта';

  @override
  String get profileDeleteCancel => 'Отменить запрос на удаление';

  @override
  String get profileEdit => 'Личные данные';

  @override
  String get profileFullName => 'Имя';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileEmailInvalid => 'Некорректный email';

  @override
  String get profileSaved => 'Сохранено';

  @override
  String get notifSettings => 'Настройки уведомлений';

  @override
  String get notifOrders => 'Статусы заказов';

  @override
  String get notifPrescriptions => 'Проверка рецептов';

  @override
  String get notifPromotions => 'Акции и предложения';

  @override
  String get notifInbox => 'Центр уведомлений';

  @override
  String get notifEmpty => 'Уведомлений пока нет';

  @override
  String get notifRxApproved => 'Рецепт одобрен';

  @override
  String get notifRxRejected => 'Рецепт отклонён';

  @override
  String get notifRxReview => 'Рецепт проверяется';

  @override
  String get notifOrderPlaced => 'Заказ оформлен';

  @override
  String get notifOrderUpdate => 'Статус заказа изменился';

  @override
  String get notifOrderCancelled => 'Заказ отменён';

  @override
  String appVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get languageTitle => 'Язык приложения';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get languageEn => 'English';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesEmpty => 'В избранном пока пусто';

  @override
  String get favoritesEmptyBody => 'Нажмите на сердечко у товара, чтобы сохранить его';

  @override
  String get favoritesGuestNote => 'Избранное хранится на устройстве. Войдите, чтобы сохранить его в аккаунте.';

  @override
  String get addressesTitle => 'Адреса доставки';

  @override
  String get addressesEmpty => 'Адресов пока нет';

  @override
  String get addressAdd => 'Добавить адрес';

  @override
  String get addressEdit => 'Изменить адрес';

  @override
  String get addressLabel => 'Название (Дом, Работа…)';

  @override
  String get addressCity => 'Город';

  @override
  String get addressStreet => 'Улица';

  @override
  String get addressHouse => 'Дом';

  @override
  String get addressApartment => 'Квартира';

  @override
  String get addressEntrance => 'Подъезд';

  @override
  String get addressFloor => 'Этаж';

  @override
  String get addressComment => 'Комментарий';

  @override
  String get addressDefault => 'Основной адрес';

  @override
  String get addressDefaultBadge => 'Основной';

  @override
  String get addressDeleteConfirm => 'Удалить этот адрес?';

  @override
  String get pharmaciesTitle => 'Аптеки';

  @override
  String pharmacyHours(String hours) {
    return 'Часы работы: $hours';
  }

  @override
  String pharmacyDistance(String km) {
    return '$km км';
  }

  @override
  String get pharmacyDelivers => 'Есть доставка';

  @override
  String get pharmacyPickupOnly => 'Только самовывоз';

  @override
  String get pharmacyCall => 'Позвонить в аптеку';

  @override
  String get pharmacyProducts => 'Товары аптеки';

  @override
  String get legalDraftNote => 'Черновик текста. Перед запуском требует проверки юристом и профильными специалистами.';

  @override
  String get privacyBody =>
      'DARMAN обрабатывает номер телефона, имя, адреса доставки, историю заказов и, по вашему желанию, фотографии рецептов — только для оформления и выполнения заказов, проверки рецептов фармацевтом и поддержки. Файлы рецептов хранятся в закрытом хранилище, доступ к ним имеют вы и уполномоченный фармацевт, каждое обращение фиксируется. Вы можете в любой момент запросить удаление аккаунта и данных в разделе «Профиль». Мы не продаём персональные данные.';

  @override
  String get termsBody =>
      'DARMAN — сервис для поиска товаров и оформления заказов в аптеках-партнёрах. Рецептурные товары отпускаются только после проверки рецепта фармацевтом. Информация в приложении носит справочный характер и не заменяет консультацию специалиста. Наличие, цены и сроки доставки определяются аптекой; указанное время доставки является ориентировочным. Отмена заказа возможна, пока аптека не начала его сборку.';

  @override
  String get helpTitle => 'Помощь и поддержка';

  @override
  String get helpFaqRxQ => 'Как заказать рецептурное лекарство?';

  @override
  String get helpFaqRxA => 'Загрузите фото рецепта в разделе «Рецепты». После одобрения фармацевтом выберите его при оформлении заказа.';

  @override
  String get helpFaqDeliveryQ => 'Как работает доставка?';

  @override
  String get helpFaqDeliveryA =>
      'Заказ выполняет одна аптека. Время доставки ориентировочное; статус обновляется по мере сборки и передачи курьеру.';

  @override
  String get helpFaqPayQ => 'Как оплатить заказ?';

  @override
  String get helpFaqPayA =>
      'Доступна оплата при получении. Онлайн-оплата картой появится после подключения платёжного провайдера; в демо-режиме деньги не списываются.';

  @override
  String get helpContact => 'Связаться с поддержкой';

  @override
  String get helpNoPhone => 'Контакты поддержки пока не настроены';

  @override
  String get helpEmergency => 'При угрозе жизни немедленно звоните 103.';

  @override
  String get themeTitle => 'Оформление';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Как в системе';
}
