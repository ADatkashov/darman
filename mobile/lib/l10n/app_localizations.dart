import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('kk'), Locale('ru')];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'DARMAN'**
  String get appName;

  /// No description provided for @slogan.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье рядом'**
  String get slogan;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get ok;

  /// No description provided for @continueAction.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueAction;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get getStarted;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @seeAll.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть все'**
  String get seeAll;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get remove;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// No description provided for @free.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатно'**
  String get free;

  /// No description provided for @demoBadge.
  ///
  /// In ru, this message translates to:
  /// **'ДЕМО'**
  String get demoBadge;

  /// No description provided for @clear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// No description provided for @optional.
  ///
  /// In ru, this message translates to:
  /// **'необязательно'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In ru, this message translates to:
  /// **'Обязательное поле'**
  String get required;

  /// No description provided for @currencySymbol.
  ///
  /// In ru, this message translates to:
  /// **'₸'**
  String get currencySymbol;

  /// No description provided for @offlineBanner.
  ///
  /// In ru, this message translates to:
  /// **'Нет подключения к интернету'**
  String get offlineBanner;

  /// No description provided for @errNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Не удаётся подключиться к серверу. Проверьте интернет и повторите.'**
  String get errNetwork;

  /// No description provided for @errServer.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера. Попробуйте позже.'**
  String get errServer;

  /// No description provided for @errUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз.'**
  String get errUnknown;

  /// No description provided for @errNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get errNotFound;

  /// No description provided for @errForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно прав'**
  String get errForbidden;

  /// No description provided for @errRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много запросов. Подождите минуту.'**
  String get errRateLimited;

  /// No description provided for @errValidation.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте введённые данные'**
  String get errValidation;

  /// No description provided for @errSessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия истекла. Войдите снова.'**
  String get errSessionExpired;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Информация в приложении не заменяет консультацию врача или фармацевта. Перед применением изучите инструкцию и проконсультируйтесь со специалистом.'**
  String get medicalDisclaimer;

  /// No description provided for @demoDataNote.
  ///
  /// In ru, this message translates to:
  /// **'Демонстрационные данные: товары и аптеки вымышлены.'**
  String get demoDataNote;

  /// No description provided for @demoModeBanner.
  ///
  /// In ru, this message translates to:
  /// **'Демо-режим: данные вымышлены, оплата и доставка не настоящие'**
  String get demoModeBanner;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get navSearch;

  /// No description provided for @navCart.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @onb1Title.
  ///
  /// In ru, this message translates to:
  /// **'Найдите нужное лекарство'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In ru, this message translates to:
  /// **'Ищите по названию, действующему веществу, бренду или дозировке.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In ru, this message translates to:
  /// **'Сравнивайте цены аптек'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ru, this message translates to:
  /// **'Смотрите предложения разных аптек, наличие и условия доставки.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт — через фармацевта'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In ru, this message translates to:
  /// **'Загрузите фото рецепта: его проверит фармацевт, где это предусмотрено законом.'**
  String get onb3Body;

  /// No description provided for @onb4Title.
  ///
  /// In ru, this message translates to:
  /// **'Доставка и отслеживание'**
  String get onb4Title;

  /// No description provided for @onb4Body.
  ///
  /// In ru, this message translates to:
  /// **'Следите за статусом заказа от подтверждения до получения.'**
  String get onb4Body;

  /// No description provided for @homeSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск лекарств и товаров'**
  String get homeSearchHint;

  /// No description provided for @homeCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get homeCategories;

  /// No description provided for @homePopular.
  ///
  /// In ru, this message translates to:
  /// **'Популярные товары'**
  String get homePopular;

  /// No description provided for @homeFrequent.
  ///
  /// In ru, this message translates to:
  /// **'Часто покупают'**
  String get homeFrequent;

  /// No description provided for @homeOffers.
  ///
  /// In ru, this message translates to:
  /// **'Акции и скидки'**
  String get homeOffers;

  /// No description provided for @homeNearby.
  ///
  /// In ru, this message translates to:
  /// **'Аптеки рядом'**
  String get homeNearby;

  /// No description provided for @homeRecent.
  ///
  /// In ru, this message translates to:
  /// **'Вы смотрели'**
  String get homeRecent;

  /// No description provided for @homeRxTitle.
  ///
  /// In ru, this message translates to:
  /// **'Есть рецепт?'**
  String get homeRxTitle;

  /// No description provided for @homeRxBody.
  ///
  /// In ru, this message translates to:
  /// **'Загрузите фото — фармацевт проверит рецепт'**
  String get homeRxBody;

  /// No description provided for @homeRxAction.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить рецепт'**
  String get homeRxAction;

  /// No description provided for @homeDeliveryInfo.
  ///
  /// In ru, this message translates to:
  /// **'Доставка по Алматы · ориентировочно {min}–{max} мин'**
  String homeDeliveryInfo(int min, int max);

  /// No description provided for @homeCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get homeCity;

  /// No description provided for @homeCitySoon.
  ///
  /// In ru, this message translates to:
  /// **'Другие города скоро появятся'**
  String get homeCitySoon;

  /// No description provided for @promoCodeBanner.
  ///
  /// In ru, this message translates to:
  /// **'Промокод {code}'**
  String promoCodeBanner(String code);

  /// No description provided for @emptySection.
  ///
  /// In ru, this message translates to:
  /// **'Пока ничего нет'**
  String get emptySection;

  /// No description provided for @searchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Название, вещество, бренд…'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавние запросы'**
  String get searchRecent;

  /// No description provided for @searchClearHistory.
  ///
  /// In ru, this message translates to:
  /// **'Очистить историю'**
  String get searchClearHistory;

  /// No description provided for @searchSuggestions.
  ///
  /// In ru, this message translates to:
  /// **'Подсказки'**
  String get searchSuggestions;

  /// No description provided for @searchFoundCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Найден {count} товар} few{Найдено {count} товара} many{Найдено {count} товаров} other{Найдено {count} товара}}'**
  String searchFoundCount(int count);

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте написание или поищите по действующему веществу. Мы не подставляем похожие, но другие товары.'**
  String get searchNoResultsBody;

  /// No description provided for @searchBrowseCategories.
  ///
  /// In ru, this message translates to:
  /// **'Посмотреть категории'**
  String get searchBrowseCategories;

  /// No description provided for @sortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sortLabel;

  /// No description provided for @sortRelevance.
  ///
  /// In ru, this message translates to:
  /// **'По релевантности'**
  String get sortRelevance;

  /// No description provided for @sortPriceAsc.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дешёвые'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дорогие'**
  String get sortPriceDesc;

  /// No description provided for @sortPopularity.
  ///
  /// In ru, this message translates to:
  /// **'По популярности'**
  String get sortPopularity;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @filterCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get filterCategory;

  /// No description provided for @filterManufacturer.
  ///
  /// In ru, this message translates to:
  /// **'Производитель'**
  String get filterManufacturer;

  /// No description provided for @filterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get filterAll;

  /// No description provided for @filterInStock.
  ///
  /// In ru, this message translates to:
  /// **'Только в наличии'**
  String get filterInStock;

  /// No description provided for @filterPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена, ₸'**
  String get filterPrice;

  /// No description provided for @filterPriceFrom.
  ///
  /// In ru, this message translates to:
  /// **'От'**
  String get filterPriceFrom;

  /// No description provided for @filterPriceTo.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get filterPriceTo;

  /// No description provided for @filterRx.
  ///
  /// In ru, this message translates to:
  /// **'Рецептурные'**
  String get filterRx;

  /// No description provided for @filterRxAny.
  ///
  /// In ru, this message translates to:
  /// **'Любые'**
  String get filterRxAny;

  /// No description provided for @filterRxOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только по рецепту'**
  String get filterRxOnly;

  /// No description provided for @filterRxNone.
  ///
  /// In ru, this message translates to:
  /// **'Без рецепта'**
  String get filterRxNone;

  /// No description provided for @loadMore.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить ещё'**
  String get loadMore;

  /// No description provided for @searchClearSemantic.
  ///
  /// In ru, this message translates to:
  /// **'Очистить поиск'**
  String get searchClearSemantic;

  /// No description provided for @productTitle.
  ///
  /// In ru, this message translates to:
  /// **'Товар'**
  String get productTitle;

  /// No description provided for @prodBrand.
  ///
  /// In ru, this message translates to:
  /// **'Бренд'**
  String get prodBrand;

  /// No description provided for @prodIngredient.
  ///
  /// In ru, this message translates to:
  /// **'Действующее вещество'**
  String get prodIngredient;

  /// No description provided for @prodStrength.
  ///
  /// In ru, this message translates to:
  /// **'Дозировка'**
  String get prodStrength;

  /// No description provided for @prodForm.
  ///
  /// In ru, this message translates to:
  /// **'Форма выпуска'**
  String get prodForm;

  /// No description provided for @prodPackage.
  ///
  /// In ru, this message translates to:
  /// **'Упаковка'**
  String get prodPackage;

  /// No description provided for @prodManufacturer.
  ///
  /// In ru, this message translates to:
  /// **'Производитель'**
  String get prodManufacturer;

  /// No description provided for @prodDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get prodDescription;

  /// No description provided for @prodUsage.
  ///
  /// In ru, this message translates to:
  /// **'Способ применения'**
  String get prodUsage;

  /// No description provided for @prodStorage.
  ///
  /// In ru, this message translates to:
  /// **'Условия хранения'**
  String get prodStorage;

  /// No description provided for @prodWarnings.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждения'**
  String get prodWarnings;

  /// No description provided for @prodContraindications.
  ///
  /// In ru, this message translates to:
  /// **'Противопоказания'**
  String get prodContraindications;

  /// No description provided for @prodComposition.
  ///
  /// In ru, this message translates to:
  /// **'Состав'**
  String get prodComposition;

  /// No description provided for @prodInfoUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Официальная инструкция недоступна. Изучите инструкцию в упаковке и проконсультируйтесь со специалистом.'**
  String get prodInfoUnavailable;

  /// No description provided for @prodInfoSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {source}'**
  String prodInfoSource(String source);

  /// No description provided for @badgeRx.
  ///
  /// In ru, this message translates to:
  /// **'По рецепту'**
  String get badgeRx;

  /// No description provided for @badgeOtc.
  ///
  /// In ru, this message translates to:
  /// **'Без рецепта'**
  String get badgeOtc;

  /// No description provided for @rxNeededNote.
  ///
  /// In ru, this message translates to:
  /// **'Для заказа нужен одобренный фармацевтом рецепт.'**
  String get rxNeededNote;

  /// No description provided for @offersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Предложения аптек'**
  String get offersTitle;

  /// No description provided for @offersBestPrice.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая цена'**
  String get offersBestPrice;

  /// No description provided for @offersNone.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас нет предложений в вашем городе'**
  String get offersNone;

  /// No description provided for @offerPickup.
  ///
  /// In ru, this message translates to:
  /// **'Самовывоз'**
  String get offerPickup;

  /// No description provided for @offerDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get offerDelivery;

  /// No description provided for @offerNoDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Без доставки'**
  String get offerNoDelivery;

  /// No description provided for @offerDeliveryFee.
  ///
  /// In ru, this message translates to:
  /// **'Доставка {fee}'**
  String offerDeliveryFee(String fee);

  /// No description provided for @offerFreeFrom.
  ///
  /// In ru, this message translates to:
  /// **'бесплатно от {amount}'**
  String offerFreeFrom(String amount);

  /// No description provided for @offerEta.
  ///
  /// In ru, this message translates to:
  /// **'≈ {min}–{max} мин (оценка)'**
  String offerEta(int min, int max);

  /// No description provided for @offerUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено {time}'**
  String offerUpdated(String time);

  /// No description provided for @stockIn.
  ///
  /// In ru, this message translates to:
  /// **'В наличии'**
  String get stockIn;

  /// No description provided for @stockLow.
  ///
  /// In ru, this message translates to:
  /// **'Мало'**
  String get stockLow;

  /// No description provided for @stockOut.
  ///
  /// In ru, this message translates to:
  /// **'Нет в наличии'**
  String get stockOut;

  /// No description provided for @stockCount.
  ///
  /// In ru, this message translates to:
  /// **'В наличии: {count} шт.'**
  String stockCount(int count);

  /// No description provided for @addToCart.
  ///
  /// In ru, this message translates to:
  /// **'В корзину'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в корзину'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get viewCart;

  /// No description provided for @favoriteAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в избранное'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из избранного'**
  String get favoriteRemove;

  /// No description provided for @selectOffer.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get selectOffer;

  /// No description provided for @offerSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано'**
  String get offerSelected;

  /// No description provided for @priceFrom.
  ///
  /// In ru, this message translates to:
  /// **'от {price}'**
  String priceFrom(String price);

  /// No description provided for @quantityDecrease.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить количество'**
  String get quantityDecrease;

  /// No description provided for @quantityIncrease.
  ///
  /// In ru, this message translates to:
  /// **'Увеличить количество'**
  String get quantityIncrease;

  /// No description provided for @quantityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество: {count}'**
  String quantityLabel(int count);

  /// No description provided for @unavailableOffer.
  ///
  /// In ru, this message translates to:
  /// **'Предложение недоступно'**
  String get unavailableOffer;

  /// No description provided for @pharmacyDemoNote.
  ///
  /// In ru, this message translates to:
  /// **'Вымышленная аптека (демо)'**
  String get pharmacyDemoNote;

  /// No description provided for @licenseNotVerified.
  ///
  /// In ru, this message translates to:
  /// **'Лицензия не проверена (демо-данные)'**
  String get licenseNotVerified;

  /// No description provided for @cartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'В корзине пока пусто'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Найдите нужные товары в каталоге и добавьте их в корзину'**
  String get cartEmptyBody;

  /// No description provided for @goToCatalog.
  ///
  /// In ru, this message translates to:
  /// **'Перейти в каталог'**
  String get goToCatalog;

  /// No description provided for @cartItems.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} товар} few{{count} товара} many{{count} товаров} other{{count} товара}}'**
  String cartItems(int count);

  /// No description provided for @cartPharmacy.
  ///
  /// In ru, this message translates to:
  /// **'Аптека: {name}'**
  String cartPharmacy(String name);

  /// No description provided for @cartPromo.
  ///
  /// In ru, this message translates to:
  /// **'Промокод'**
  String get cartPromo;

  /// No description provided for @cartPromoHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите промокод'**
  String get cartPromoHint;

  /// No description provided for @cartPromoApplied.
  ///
  /// In ru, this message translates to:
  /// **'Промокод применён: −{amount}'**
  String cartPromoApplied(String amount);

  /// No description provided for @cartPromoInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Промокод не подходит'**
  String get cartPromoInvalid;

  /// No description provided for @cartPromoMin.
  ///
  /// In ru, this message translates to:
  /// **'Минимальная сумма заказа для промокода не достигнута'**
  String get cartPromoMin;

  /// No description provided for @cartSubtotal.
  ///
  /// In ru, this message translates to:
  /// **'Товары'**
  String get cartSubtotal;

  /// No description provided for @cartDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get cartDelivery;

  /// No description provided for @cartDiscount.
  ///
  /// In ru, this message translates to:
  /// **'Скидка'**
  String get cartDiscount;

  /// No description provided for @cartTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In ru, this message translates to:
  /// **'Оформить заказ'**
  String get cartCheckout;

  /// No description provided for @cartClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить корзину'**
  String get cartClear;

  /// No description provided for @cartClearConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все товары из корзины?'**
  String get cartClearConfirm;

  /// No description provided for @cartBranchMismatchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Товары из другой аптеки'**
  String get cartBranchMismatchTitle;

  /// No description provided for @cartBranchMismatchBody.
  ///
  /// In ru, this message translates to:
  /// **'Заказ выполняет одна аптека. В корзине уже есть товары из «{name}». Заменить корзину?'**
  String cartBranchMismatchBody(String name);

  /// No description provided for @cartReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get cartReplace;

  /// No description provided for @cartKeep.
  ///
  /// In ru, this message translates to:
  /// **'Оставить'**
  String get cartKeep;

  /// No description provided for @cartIssuePrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена изменилась: было {old}, стало {now}'**
  String cartIssuePrice(String old, String now);

  /// No description provided for @cartIssueOut.
  ///
  /// In ru, this message translates to:
  /// **'Нет в наличии'**
  String get cartIssueOut;

  /// No description provided for @cartIssueLow.
  ///
  /// In ru, this message translates to:
  /// **'Доступно только {count} шт.'**
  String cartIssueLow(int count);

  /// No description provided for @cartIssueUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Предложение больше недоступно'**
  String get cartIssueUnavailable;

  /// No description provided for @cartFixIssues.
  ///
  /// In ru, this message translates to:
  /// **'Уберите недоступные товары или измените количество'**
  String get cartFixIssues;

  /// No description provided for @cartCheckFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить наличие и цены. Они будут перепроверены при оформлении.'**
  String get cartCheckFailed;

  /// No description provided for @cartRxNeeded.
  ///
  /// In ru, this message translates to:
  /// **'В корзине есть рецептурные товары — для заказа нужен одобренный рецепт'**
  String get cartRxNeeded;

  /// No description provided for @cartFreeDeliveryFrom.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатная доставка от {amount}'**
  String cartFreeDeliveryFrom(String amount);

  /// No description provided for @cartDeliveryUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Эта аптека не доставляет — доступен самовывоз'**
  String get cartDeliveryUnavailable;

  /// No description provided for @cartRemoveItem.
  ///
  /// In ru, this message translates to:
  /// **'Удалить {name} из корзины'**
  String cartRemoveItem(String name);

  /// No description provided for @checkoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление заказа'**
  String get checkoutTitle;

  /// No description provided for @coContact.
  ///
  /// In ru, this message translates to:
  /// **'Контакты'**
  String get coContact;

  /// No description provided for @coName.
  ///
  /// In ru, this message translates to:
  /// **'Имя получателя'**
  String get coName;

  /// No description provided for @coPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get coPhone;

  /// No description provided for @coFulfillment.
  ///
  /// In ru, this message translates to:
  /// **'Способ получения'**
  String get coFulfillment;

  /// No description provided for @coDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get coDelivery;

  /// No description provided for @coPickup.
  ///
  /// In ru, this message translates to:
  /// **'Самовывоз'**
  String get coPickup;

  /// No description provided for @coPickupFrom.
  ///
  /// In ru, this message translates to:
  /// **'Заберите в аптеке: {address}'**
  String coPickupFrom(String address);

  /// No description provided for @coAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес доставки'**
  String get coAddress;

  /// No description provided for @coChooseAddress.
  ///
  /// In ru, this message translates to:
  /// **'Выберите адрес'**
  String get coChooseAddress;

  /// No description provided for @coAddAddress.
  ///
  /// In ru, this message translates to:
  /// **'Добавить адрес'**
  String get coAddAddress;

  /// No description provided for @coNotes.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий для курьера'**
  String get coNotes;

  /// No description provided for @coSlot.
  ///
  /// In ru, this message translates to:
  /// **'Время доставки'**
  String get coSlot;

  /// No description provided for @coAsap.
  ///
  /// In ru, this message translates to:
  /// **'Как можно скорее · ≈ {min}–{max} мин (оценка)'**
  String coAsap(int min, int max);

  /// No description provided for @coSlotToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get coSlotToday;

  /// No description provided for @coSlotTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get coSlotTomorrow;

  /// No description provided for @coPayment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get coPayment;

  /// No description provided for @coPayCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличными при получении'**
  String get coPayCash;

  /// No description provided for @coPayCard.
  ///
  /// In ru, this message translates to:
  /// **'Банковской картой онлайн'**
  String get coPayCard;

  /// No description provided for @coPayCardDemo.
  ///
  /// In ru, this message translates to:
  /// **'Картой онлайн — ДЕМО (деньги не списываются)'**
  String get coPayCardDemo;

  /// No description provided for @coPayCardUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-оплата сейчас недоступна'**
  String get coPayCardUnavailable;

  /// No description provided for @coRxSection.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт'**
  String get coRxSection;

  /// No description provided for @coRxChoose.
  ///
  /// In ru, this message translates to:
  /// **'Выберите одобренный рецепт'**
  String get coRxChoose;

  /// No description provided for @coRxNone.
  ///
  /// In ru, this message translates to:
  /// **'Нет одобренных рецептов. Загрузите рецепт и дождитесь проверки фармацевтом.'**
  String get coRxNone;

  /// No description provided for @coRxUpload.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить рецепт'**
  String get coRxUpload;

  /// No description provided for @coRxLine.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт от {date}'**
  String coRxLine(String date);

  /// No description provided for @coConsent.
  ///
  /// In ru, this message translates to:
  /// **'Я согласен(на) с Политикой конфиденциальности и Условиями использования'**
  String get coConsent;

  /// No description provided for @coConsentRequired.
  ///
  /// In ru, this message translates to:
  /// **'Необходимо согласие для оформления заказа'**
  String get coConsentRequired;

  /// No description provided for @coPlaceOrder.
  ///
  /// In ru, this message translates to:
  /// **'Оформить заказ · {total}'**
  String coPlaceOrder(String total);

  /// No description provided for @coPlacing.
  ///
  /// In ru, this message translates to:
  /// **'Оформляем…'**
  String get coPlacing;

  /// No description provided for @coSummary.
  ///
  /// In ru, this message translates to:
  /// **'Ваш заказ'**
  String get coSummary;

  /// No description provided for @coPriceChangedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цены изменились'**
  String get coPriceChangedTitle;

  /// No description provided for @coPriceChangedBody.
  ///
  /// In ru, this message translates to:
  /// **'Пока вы оформляли заказ, цены или наличие изменились. Проверьте корзину и повторите.'**
  String get coPriceChangedBody;

  /// No description provided for @coDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ оформлен'**
  String get coDoneTitle;

  /// No description provided for @coDoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Номер заказа: {number}'**
  String coDoneBody(String number);

  /// No description provided for @coDoneDemo.
  ///
  /// In ru, this message translates to:
  /// **'Демо-заказ: настоящая оплата и доставка не выполняются'**
  String get coDoneDemo;

  /// No description provided for @coViewOrder.
  ///
  /// In ru, this message translates to:
  /// **'Следить за заказом'**
  String get coViewOrder;

  /// No description provided for @coBackHome.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get coBackHome;

  /// No description provided for @coLoginRequired.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы оформить заказ'**
  String get coLoginRequired;

  /// No description provided for @errPrescriptionRequired.
  ///
  /// In ru, this message translates to:
  /// **'Для этих товаров нужен одобренный рецепт'**
  String get errPrescriptionRequired;

  /// No description provided for @errPrescriptionNotApproved.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт ещё не одобрен или срок его действия истёк'**
  String get errPrescriptionNotApproved;

  /// No description provided for @errPrescriptionUsed.
  ///
  /// In ru, this message translates to:
  /// **'Этот рецепт уже использован в другом заказе'**
  String get errPrescriptionUsed;

  /// No description provided for @errInsufficientStock.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно товара в наличии'**
  String get errInsufficientStock;

  /// No description provided for @errOfferUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Один из товаров больше недоступен'**
  String get errOfferUnavailable;

  /// No description provided for @errMixedBranches.
  ///
  /// In ru, this message translates to:
  /// **'Товары должны быть из одной аптеки'**
  String get errMixedBranches;

  /// No description provided for @errDeliveryUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Эта аптека не доставляет'**
  String get errDeliveryUnavailable;

  /// No description provided for @errSlotInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Выбранное время доставки больше недоступно'**
  String get errSlotInvalid;

  /// No description provided for @errAddressRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите адрес доставки'**
  String get errAddressRequired;

  /// No description provided for @errPaymentUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-оплата недоступна. Выберите оплату при получении.'**
  String get errPaymentUnavailable;

  /// No description provided for @errPaymentFailed.
  ///
  /// In ru, this message translates to:
  /// **'Платёж отклонён'**
  String get errPaymentFailed;

  /// No description provided for @errPhoneInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер в формате +7 XXX XXX XX XX'**
  String get errPhoneInvalid;

  /// No description provided for @errCancelNotAllowed.
  ///
  /// In ru, this message translates to:
  /// **'Заказ уже нельзя отменить'**
  String get errCancelNotAllowed;

  /// No description provided for @ordersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои заказы'**
  String get ordersTitle;

  /// No description provided for @ordersActive.
  ///
  /// In ru, this message translates to:
  /// **'Текущие'**
  String get ordersActive;

  /// No description provided for @ordersHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get ordersHistory;

  /// No description provided for @ordersEmptyActive.
  ///
  /// In ru, this message translates to:
  /// **'Нет текущих заказов'**
  String get ordersEmptyActive;

  /// No description provided for @ordersEmptyHistory.
  ///
  /// In ru, this message translates to:
  /// **'История заказов пуста'**
  String get ordersEmptyHistory;

  /// No description provided for @ordersGuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы видеть заказы'**
  String get ordersGuestTitle;

  /// No description provided for @ordersGuestBody.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся ваши заказы и их статусы'**
  String get ordersGuestBody;

  /// No description provided for @orderNumber.
  ///
  /// In ru, this message translates to:
  /// **'Заказ № {number}'**
  String orderNumber(String number);

  /// No description provided for @orderDetails.
  ///
  /// In ru, this message translates to:
  /// **'Детали заказа'**
  String get orderDetails;

  /// No description provided for @orderDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get orderDelivery;

  /// No description provided for @orderTracking.
  ///
  /// In ru, this message translates to:
  /// **'Отслеживание'**
  String get orderTracking;

  /// No description provided for @statusPlaced.
  ///
  /// In ru, this message translates to:
  /// **'Заказ оформлен'**
  String get statusPlaced;

  /// No description provided for @statusConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждён'**
  String get statusConfirmed;

  /// No description provided for @statusPreparing.
  ///
  /// In ru, this message translates to:
  /// **'Собирается'**
  String get statusPreparing;

  /// No description provided for @statusReadyForPickup.
  ///
  /// In ru, this message translates to:
  /// **'Готов к выдаче'**
  String get statusReadyForPickup;

  /// No description provided for @statusInTransit.
  ///
  /// In ru, this message translates to:
  /// **'В пути'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In ru, this message translates to:
  /// **'Доставлен'**
  String get statusDelivered;

  /// No description provided for @statusDeliveredPickup.
  ///
  /// In ru, this message translates to:
  /// **'Выдан'**
  String get statusDeliveredPickup;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get statusCancelled;

  /// No description provided for @statusInTransitHint.
  ///
  /// In ru, this message translates to:
  /// **'Курьер направляется к вам'**
  String get statusInTransitHint;

  /// No description provided for @statusPreparingHint.
  ///
  /// In ru, this message translates to:
  /// **'Аптека собирает ваш заказ'**
  String get statusPreparingHint;

  /// No description provided for @orderWindow.
  ///
  /// In ru, this message translates to:
  /// **'Окно доставки'**
  String get orderWindow;

  /// No description provided for @orderEtaEstimate.
  ///
  /// In ru, this message translates to:
  /// **'Ориентировочно {from}–{to}'**
  String orderEtaEstimate(String from, String to);

  /// No description provided for @orderAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес доставки'**
  String get orderAddress;

  /// No description provided for @orderPickupAddress.
  ///
  /// In ru, this message translates to:
  /// **'Пункт выдачи'**
  String get orderPickupAddress;

  /// No description provided for @orderCourier.
  ///
  /// In ru, this message translates to:
  /// **'Курьер'**
  String get orderCourier;

  /// No description provided for @orderCourierDemo.
  ///
  /// In ru, this message translates to:
  /// **'Демо-курьер (вымышленный)'**
  String get orderCourierDemo;

  /// No description provided for @orderCall.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить'**
  String get orderCall;

  /// No description provided for @orderNoCourier.
  ///
  /// In ru, this message translates to:
  /// **'Курьер будет назначен перед отправкой'**
  String get orderNoCourier;

  /// No description provided for @orderItems.
  ///
  /// In ru, this message translates to:
  /// **'Состав заказа'**
  String get orderItems;

  /// No description provided for @orderSupport.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get orderSupport;

  /// No description provided for @orderSupportBody.
  ///
  /// In ru, this message translates to:
  /// **'Нужна помощь с заказом? Свяжитесь с аптекой или поддержкой.'**
  String get orderSupportBody;

  /// No description provided for @orderContactPharmacy.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с аптекой'**
  String get orderContactPharmacy;

  /// No description provided for @orderCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить заказ'**
  String get orderCancel;

  /// No description provided for @orderCancelConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Отменить этот заказ? Товары вернутся на склад.'**
  String get orderCancelConfirm;

  /// No description provided for @orderCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отменён'**
  String get orderCancelled;

  /// No description provided for @orderReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Квитанция'**
  String get orderReceipt;

  /// No description provided for @orderReceiptNotice.
  ///
  /// In ru, this message translates to:
  /// **'Это справка о заказе, а не фискальный чек.'**
  String get orderReceiptNotice;

  /// No description provided for @orderReorder.
  ///
  /// In ru, this message translates to:
  /// **'Повторить заказ'**
  String get orderReorder;

  /// No description provided for @orderReorderDone.
  ///
  /// In ru, this message translates to:
  /// **'{added, plural, one{Добавлен {added} товар} few{Добавлено {added} товара} many{Добавлено {added} товаров} other{Добавлено {added} товара}} в корзину'**
  String orderReorderDone(int added);

  /// No description provided for @orderReorderSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Часть товаров недоступна и не добавлена: {count}'**
  String orderReorderSkipped(int count);

  /// No description provided for @orderReorderChanged.
  ///
  /// In ru, this message translates to:
  /// **'Цены или количество изменились — проверьте корзину'**
  String get orderReorderChanged;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История статусов'**
  String get orderHistoryTitle;

  /// No description provided for @payUnpaid.
  ///
  /// In ru, this message translates to:
  /// **'Оплата при получении'**
  String get payUnpaid;

  /// No description provided for @payPending.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает оплаты'**
  String get payPending;

  /// No description provided for @payPaid.
  ///
  /// In ru, this message translates to:
  /// **'Оплачено'**
  String get payPaid;

  /// No description provided for @payDemoPaid.
  ///
  /// In ru, this message translates to:
  /// **'Демо-оплата (деньги не списаны)'**
  String get payDemoPaid;

  /// No description provided for @payFailed.
  ///
  /// In ru, this message translates to:
  /// **'Платёж не прошёл'**
  String get payFailed;

  /// No description provided for @payRefundPending.
  ///
  /// In ru, this message translates to:
  /// **'Возврат в обработке'**
  String get payRefundPending;

  /// No description provided for @payRefunded.
  ///
  /// In ru, this message translates to:
  /// **'Возвращено'**
  String get payRefunded;

  /// No description provided for @orderPayment.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get orderPayment;

  /// No description provided for @orderFulfillmentDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get orderFulfillmentDelivery;

  /// No description provided for @orderFulfillmentPickup.
  ///
  /// In ru, this message translates to:
  /// **'Самовывоз'**
  String get orderFulfillmentPickup;

  /// No description provided for @orderSimulatedNote.
  ///
  /// In ru, this message translates to:
  /// **'Статусы демо-заказов меняются автоматически для демонстрации. Реальный курьер и GPS не подключены.'**
  String get orderSimulatedNote;

  /// No description provided for @rxTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рецепты'**
  String get rxTitle;

  /// No description provided for @rxUploadTitle.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка рецепта'**
  String get rxUploadTitle;

  /// No description provided for @rxUploadHint.
  ///
  /// In ru, this message translates to:
  /// **'Поддерживаются фото и PDF (JPG, PNG, PDF) до {size} МБ'**
  String rxUploadHint(int size);

  /// No description provided for @rxLegal.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт проверяет фармацевт. Загрузка файла не означает одобрения.'**
  String get rxLegal;

  /// No description provided for @rxTakePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Сфотографировать'**
  String get rxTakePhoto;

  /// No description provided for @rxGallery.
  ///
  /// In ru, this message translates to:
  /// **'Из галереи'**
  String get rxGallery;

  /// No description provided for @rxPdf.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать PDF'**
  String get rxPdf;

  /// No description provided for @rxAddMore.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ещё'**
  String get rxAddMore;

  /// No description provided for @rxNote.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий (необязательно)'**
  String get rxNote;

  /// No description provided for @rxSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Отправить на проверку'**
  String get rxSubmit;

  /// No description provided for @rxUploading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка {percent}%'**
  String rxUploading(int percent);

  /// No description provided for @rxSubmittedOk.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт отправлен на проверку'**
  String get rxSubmittedOk;

  /// No description provided for @rxStatusDraft.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get rxStatusDraft;

  /// No description provided for @rxStatusSubmitted.
  ///
  /// In ru, this message translates to:
  /// **'Отправлен'**
  String get rxStatusSubmitted;

  /// No description provided for @rxStatusUnderReview.
  ///
  /// In ru, this message translates to:
  /// **'На проверке'**
  String get rxStatusUnderReview;

  /// No description provided for @rxStatusApproved.
  ///
  /// In ru, this message translates to:
  /// **'Одобрен'**
  String get rxStatusApproved;

  /// No description provided for @rxStatusRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонён'**
  String get rxStatusRejected;

  /// No description provided for @rxStatusExpired.
  ///
  /// In ru, this message translates to:
  /// **'Срок истёк'**
  String get rxStatusExpired;

  /// No description provided for @rxRejectionReason.
  ///
  /// In ru, this message translates to:
  /// **'Причина отказа: {reason}'**
  String rxRejectionReason(String reason);

  /// No description provided for @rxValidUntil.
  ///
  /// In ru, this message translates to:
  /// **'Действителен до {date}'**
  String rxValidUntil(String date);

  /// No description provided for @rxHistory.
  ///
  /// In ru, this message translates to:
  /// **'Мои рецепты'**
  String get rxHistory;

  /// No description provided for @rxEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Вы ещё не загружали рецепты'**
  String get rxEmpty;

  /// No description provided for @rxFilesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} файл} few{{count} файла} many{{count} файлов} other{{count} файла}}'**
  String rxFilesCount(int count);

  /// No description provided for @rxTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Файл больше {size} МБ'**
  String rxTooLarge(int size);

  /// No description provided for @rxBadType.
  ///
  /// In ru, this message translates to:
  /// **'Допустимы только JPG, PNG и PDF'**
  String get rxBadType;

  /// No description provided for @rxMaxFiles.
  ///
  /// In ru, this message translates to:
  /// **'Не более {count} файлов'**
  String rxMaxFiles(int count);

  /// No description provided for @rxNoFiles.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы один файл'**
  String get rxNoFiles;

  /// No description provided for @rxDemoReview.
  ///
  /// In ru, this message translates to:
  /// **'Демо-проверка: это не проверка настоящим фармацевтом'**
  String get rxDemoReview;

  /// No description provided for @rxTimeline.
  ///
  /// In ru, this message translates to:
  /// **'Ход проверки'**
  String get rxTimeline;

  /// No description provided for @rxEventCreated.
  ///
  /// In ru, this message translates to:
  /// **'Черновик создан'**
  String get rxEventCreated;

  /// No description provided for @rxEventSubmitted.
  ///
  /// In ru, this message translates to:
  /// **'Отправлен на проверку'**
  String get rxEventSubmitted;

  /// No description provided for @rxEventReviewStarted.
  ///
  /// In ru, this message translates to:
  /// **'Проверка началась'**
  String get rxEventReviewStarted;

  /// No description provided for @rxEventApproved.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт одобрен'**
  String get rxEventApproved;

  /// No description provided for @rxEventRejected.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт отклонён'**
  String get rxEventRejected;

  /// No description provided for @rxEventExpired.
  ///
  /// In ru, this message translates to:
  /// **'Срок действия истёк'**
  String get rxEventExpired;

  /// No description provided for @rxUsable.
  ///
  /// In ru, this message translates to:
  /// **'Можно использовать в заказе'**
  String get rxUsable;

  /// No description provided for @rxDeleteDraft.
  ///
  /// In ru, this message translates to:
  /// **'Удалить черновик'**
  String get rxDeleteDraft;

  /// No description provided for @rxLoginRequired.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы загрузить рецепт'**
  String get rxLoginRequired;

  /// No description provided for @rxFileRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать файл'**
  String get rxFileRemove;

  /// No description provided for @rxNewShort.
  ///
  /// In ru, this message translates to:
  /// **'Новый рецепт'**
  String get rxNewShort;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите по номеру телефона'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердим номер по коду'**
  String get registerSubtitle;

  /// No description provided for @authPhone.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get authPhone;

  /// No description provided for @authPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Не менее 8 символов, буквы и цифры'**
  String get authPasswordHint;

  /// No description provided for @authFullName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get authFullName;

  /// No description provided for @authConsent.
  ///
  /// In ru, this message translates to:
  /// **'Я принимаю Политику конфиденциальности и согласен на обработку персональных данных'**
  String get authConsent;

  /// No description provided for @authConsentRequired.
  ///
  /// In ru, this message translates to:
  /// **'Необходимо согласие на обработку данных'**
  String get authConsentRequired;

  /// No description provided for @authLoginAction.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authLoginAction;

  /// No description provided for @authRegisterAction.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get authRegisterAction;

  /// No description provided for @authNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрируйтесь'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войдите'**
  String get authHaveAccount;

  /// No description provided for @authContinueGuest.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить без входа'**
  String get authContinueGuest;

  /// No description provided for @otpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение номера'**
  String get otpTitle;

  /// No description provided for @otpBody.
  ///
  /// In ru, this message translates to:
  /// **'Введите код, отправленный на {phone}'**
  String otpBody(String phone);

  /// No description provided for @otpDemoNote.
  ///
  /// In ru, this message translates to:
  /// **'ДЕМО: код {code}. В рабочем режиме код приходит по SMS.'**
  String otpDemoNote(String code);

  /// No description provided for @otpResend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код ещё раз'**
  String get otpResend;

  /// No description provided for @otpResendIn.
  ///
  /// In ru, this message translates to:
  /// **'Повторно через {seconds} с'**
  String otpResendIn(int seconds);

  /// No description provided for @otpVerify.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get otpVerify;

  /// No description provided for @otpCode.
  ///
  /// In ru, this message translates to:
  /// **'Код из SMS'**
  String get otpCode;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверный телефон или пароль'**
  String get errInvalidCredentials;

  /// No description provided for @errPhoneNotVerified.
  ///
  /// In ru, this message translates to:
  /// **'Номер не подтверждён. Завершите регистрацию.'**
  String get errPhoneNotVerified;

  /// No description provided for @errPhoneExists.
  ///
  /// In ru, this message translates to:
  /// **'Этот номер уже зарегистрирован'**
  String get errPhoneExists;

  /// No description provided for @errWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен содержать буквы и цифры (от 8 символов)'**
  String get errWeakPassword;

  /// No description provided for @errOtpInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный или просроченный код'**
  String get errOtpInvalid;

  /// No description provided for @errOtpTooSoon.
  ///
  /// In ru, this message translates to:
  /// **'Код уже отправлен. Подождите немного.'**
  String get errOtpTooSoon;

  /// No description provided for @errOtpUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Сервис SMS-подтверждения сейчас недоступен'**
  String get errOtpUnavailable;

  /// No description provided for @errAccountDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт отключён'**
  String get errAccountDisabled;

  /// No description provided for @passwordShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get passwordHide;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileGuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в DARMAN'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы оформлять заказы, сохранять адреса и рецепты'**
  String get profileGuestBody;

  /// No description provided for @profileLoginRegister.
  ///
  /// In ru, this message translates to:
  /// **'Войти или зарегистрироваться'**
  String get profileLoginRegister;

  /// No description provided for @profileMyOrders.
  ///
  /// In ru, this message translates to:
  /// **'Мои заказы'**
  String get profileMyOrders;

  /// No description provided for @profileRx.
  ///
  /// In ru, this message translates to:
  /// **'Рецепты'**
  String get profileRx;

  /// No description provided for @profileAddresses.
  ///
  /// In ru, this message translates to:
  /// **'Адреса доставки'**
  String get profileAddresses;

  /// No description provided for @profileFavorites.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get profileFavorites;

  /// No description provided for @profileNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get profileNotifications;

  /// No description provided for @profileLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get profileLanguage;

  /// No description provided for @profilePrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get profilePrivacy;

  /// No description provided for @profileTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get profileTerms;

  /// No description provided for @profileHelp.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и поддержка'**
  String get profileHelp;

  /// No description provided for @profileLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get profileDelete;

  /// No description provided for @profileDeleteBody.
  ///
  /// In ru, this message translates to:
  /// **'Мы примем запрос на удаление аккаунта и персональных данных. Заказы, которые нужно хранить по закону, могут сохраняться в обезличенном виде. Запрос можно отменить.'**
  String get profileDeleteBody;

  /// No description provided for @profileDeleteRequested.
  ///
  /// In ru, this message translates to:
  /// **'Запрос на удаление отправлен'**
  String get profileDeleteRequested;

  /// No description provided for @profileDeletePending.
  ///
  /// In ru, this message translates to:
  /// **'Запрошено удаление аккаунта'**
  String get profileDeletePending;

  /// No description provided for @profileDeleteCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить запрос на удаление'**
  String get profileDeleteCancel;

  /// No description provided for @profileEdit.
  ///
  /// In ru, this message translates to:
  /// **'Личные данные'**
  String get profileEdit;

  /// No description provided for @profileFullName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get profileFullName;

  /// No description provided for @profileEmail.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get profileEmail;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email'**
  String get profileEmailInvalid;

  /// No description provided for @profileSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get profileSaved;

  /// No description provided for @notifSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки уведомлений'**
  String get notifSettings;

  /// No description provided for @notifOrders.
  ///
  /// In ru, this message translates to:
  /// **'Статусы заказов'**
  String get notifOrders;

  /// No description provided for @notifPrescriptions.
  ///
  /// In ru, this message translates to:
  /// **'Проверка рецептов'**
  String get notifPrescriptions;

  /// No description provided for @notifPromotions.
  ///
  /// In ru, this message translates to:
  /// **'Акции и предложения'**
  String get notifPromotions;

  /// No description provided for @notifInbox.
  ///
  /// In ru, this message translates to:
  /// **'Центр уведомлений'**
  String get notifInbox;

  /// No description provided for @notifEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Уведомлений пока нет'**
  String get notifEmpty;

  /// No description provided for @notifRxApproved.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт одобрен'**
  String get notifRxApproved;

  /// No description provided for @notifRxRejected.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт отклонён'**
  String get notifRxRejected;

  /// No description provided for @notifRxReview.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт проверяется'**
  String get notifRxReview;

  /// No description provided for @notifOrderPlaced.
  ///
  /// In ru, this message translates to:
  /// **'Заказ оформлен'**
  String get notifOrderPlaced;

  /// No description provided for @notifOrderUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Статус заказа изменился'**
  String get notifOrderUpdate;

  /// No description provided for @notifOrderCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заказ отменён'**
  String get notifOrderCancelled;

  /// No description provided for @appVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String appVersion(String version);

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageTitle;

  /// No description provided for @languageRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageKk.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get languageKk;

  /// No description provided for @languageEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @favoritesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В избранном пока пусто'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите на сердечко у товара, чтобы сохранить его'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesGuestNote.
  ///
  /// In ru, this message translates to:
  /// **'Избранное хранится на устройстве. Войдите, чтобы сохранить его в аккаунте.'**
  String get favoritesGuestNote;

  /// No description provided for @addressesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Адреса доставки'**
  String get addressesTitle;

  /// No description provided for @addressesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Адресов пока нет'**
  String get addressesEmpty;

  /// No description provided for @addressAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить адрес'**
  String get addressAdd;

  /// No description provided for @addressEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить адрес'**
  String get addressEdit;

  /// No description provided for @addressLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название (Дом, Работа…)'**
  String get addressLabel;

  /// No description provided for @addressCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get addressCity;

  /// No description provided for @addressStreet.
  ///
  /// In ru, this message translates to:
  /// **'Улица'**
  String get addressStreet;

  /// No description provided for @addressHouse.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get addressHouse;

  /// No description provided for @addressApartment.
  ///
  /// In ru, this message translates to:
  /// **'Квартира'**
  String get addressApartment;

  /// No description provided for @addressEntrance.
  ///
  /// In ru, this message translates to:
  /// **'Подъезд'**
  String get addressEntrance;

  /// No description provided for @addressFloor.
  ///
  /// In ru, this message translates to:
  /// **'Этаж'**
  String get addressFloor;

  /// No description provided for @addressComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get addressComment;

  /// No description provided for @addressDefault.
  ///
  /// In ru, this message translates to:
  /// **'Основной адрес'**
  String get addressDefault;

  /// No description provided for @addressDefaultBadge.
  ///
  /// In ru, this message translates to:
  /// **'Основной'**
  String get addressDefaultBadge;

  /// No description provided for @addressDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить этот адрес?'**
  String get addressDeleteConfirm;

  /// No description provided for @pharmaciesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аптеки'**
  String get pharmaciesTitle;

  /// No description provided for @pharmacyHours.
  ///
  /// In ru, this message translates to:
  /// **'Часы работы: {hours}'**
  String pharmacyHours(String hours);

  /// No description provided for @pharmacyDistance.
  ///
  /// In ru, this message translates to:
  /// **'{km} км'**
  String pharmacyDistance(String km);

  /// No description provided for @pharmacyDelivers.
  ///
  /// In ru, this message translates to:
  /// **'Есть доставка'**
  String get pharmacyDelivers;

  /// No description provided for @pharmacyPickupOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только самовывоз'**
  String get pharmacyPickupOnly;

  /// No description provided for @pharmacyCall.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить в аптеку'**
  String get pharmacyCall;

  /// No description provided for @pharmacyProducts.
  ///
  /// In ru, this message translates to:
  /// **'Товары аптеки'**
  String get pharmacyProducts;

  /// No description provided for @legalDraftNote.
  ///
  /// In ru, this message translates to:
  /// **'Черновик текста. Перед запуском требует проверки юристом и профильными специалистами.'**
  String get legalDraftNote;

  /// No description provided for @privacyBody.
  ///
  /// In ru, this message translates to:
  /// **'DARMAN обрабатывает номер телефона, имя, адреса доставки, историю заказов и, по вашему желанию, фотографии рецептов — только для оформления и выполнения заказов, проверки рецептов фармацевтом и поддержки. Файлы рецептов хранятся в закрытом хранилище, доступ к ним имеют вы и уполномоченный фармацевт, каждое обращение фиксируется. Вы можете в любой момент запросить удаление аккаунта и данных в разделе «Профиль». Мы не продаём персональные данные.'**
  String get privacyBody;

  /// No description provided for @termsBody.
  ///
  /// In ru, this message translates to:
  /// **'DARMAN — сервис для поиска товаров и оформления заказов в аптеках-партнёрах. Рецептурные товары отпускаются только после проверки рецепта фармацевтом. Информация в приложении носит справочный характер и не заменяет консультацию специалиста. Наличие, цены и сроки доставки определяются аптекой; указанное время доставки является ориентировочным. Отмена заказа возможна, пока аптека не начала его сборку.'**
  String get termsBody;

  /// No description provided for @helpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и поддержка'**
  String get helpTitle;

  /// No description provided for @helpFaqRxQ.
  ///
  /// In ru, this message translates to:
  /// **'Как заказать рецептурное лекарство?'**
  String get helpFaqRxQ;

  /// No description provided for @helpFaqRxA.
  ///
  /// In ru, this message translates to:
  /// **'Загрузите фото рецепта в разделе «Рецепты». После одобрения фармацевтом выберите его при оформлении заказа.'**
  String get helpFaqRxA;

  /// No description provided for @helpFaqDeliveryQ.
  ///
  /// In ru, this message translates to:
  /// **'Как работает доставка?'**
  String get helpFaqDeliveryQ;

  /// No description provided for @helpFaqDeliveryA.
  ///
  /// In ru, this message translates to:
  /// **'Заказ выполняет одна аптека. Время доставки ориентировочное; статус обновляется по мере сборки и передачи курьеру.'**
  String get helpFaqDeliveryA;

  /// No description provided for @helpFaqPayQ.
  ///
  /// In ru, this message translates to:
  /// **'Как оплатить заказ?'**
  String get helpFaqPayQ;

  /// No description provided for @helpFaqPayA.
  ///
  /// In ru, this message translates to:
  /// **'Доступна оплата при получении. Онлайн-оплата картой появится после подключения платёжного провайдера; в демо-режиме деньги не списываются.'**
  String get helpFaqPayA;

  /// No description provided for @helpContact.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с поддержкой'**
  String get helpContact;

  /// No description provided for @helpNoPhone.
  ///
  /// In ru, this message translates to:
  /// **'Контакты поддержки пока не настроены'**
  String get helpNoPhone;

  /// No description provided for @helpEmergency.
  ///
  /// In ru, this message translates to:
  /// **'При угрозе жизни немедленно звоните 103.'**
  String get helpEmergency;

  /// No description provided for @themeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'kk':
      return AppL10nKk();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
