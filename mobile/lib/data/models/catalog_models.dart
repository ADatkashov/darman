import 'json_util.dart';

class Category {
  const Category({required this.id, required this.slug, required this.name, required this.icon, required this.productCount});
  final String id;
  final String slug;
  final String name;
  final String icon;
  final int productCount;

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as String,
    slug: j['slug'] as String,
    name: j['name'] as String,
    icon: (j['icon'] as String?) ?? 'medication',
    productCount: intOr(j['productCount']),
  );
}

/// Compact product used in lists. [bestOfferId] is the cheapest in-stock offer (null when nothing is in stock).
class ProductCard {
  const ProductCard({
    required this.id,
    required this.slug,
    required this.name,
    this.brand,
    this.activeIngredient,
    this.strength,
    this.dosageForm,
    this.packageSize,
    this.manufacturer,
    required this.categorySlug,
    required this.rxRequired,
    this.imageUrl,
    this.price,
    this.oldPrice,
    this.bestOfferId,
    this.pharmacyName,
    this.branchName,
    required this.availableOffers,
    required this.inStock,
    required this.demo,
  });

  final String id;
  final String slug;
  final String name;
  final String? brand;
  final String? activeIngredient;
  final String? strength;
  final String? dosageForm;
  final String? packageSize;
  final String? manufacturer;
  final String categorySlug;
  final bool rxRequired;
  final String? imageUrl;
  final double? price;
  final double? oldPrice;
  final String? bestOfferId;
  final String? pharmacyName;
  final String? branchName;
  final int availableOffers;
  final bool inStock;
  final bool demo;

  factory ProductCard.fromJson(Map<String, dynamic> j) => ProductCard(
    id: j['id'] as String,
    slug: j['slug'] as String,
    name: j['name'] as String,
    brand: j['brand'] as String?,
    activeIngredient: j['activeIngredient'] as String?,
    strength: j['strength'] as String?,
    dosageForm: j['dosageForm'] as String?,
    packageSize: j['packageSize'] as String?,
    manufacturer: j['manufacturer'] as String?,
    categorySlug: (j['categorySlug'] as String?) ?? '',
    rxRequired: (j['rxRequired'] as bool?) ?? false,
    imageUrl: j['imageUrl'] as String?,
    price: dblOrNull(j['price']),
    oldPrice: dblOrNull(j['oldPrice']),
    bestOfferId: j['bestOfferId'] as String?,
    pharmacyName: j['pharmacyName'] as String?,
    branchName: j['branchName'] as String?,
    availableOffers: intOr(j['availableOffers']),
    inStock: (j['inStock'] as bool?) ?? false,
    demo: (j['demo'] as bool?) ?? false,
  );

  /// "200 мг · таблетки · 20 шт"
  String get specLine => [strength, dosageForm, packageSize].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
}

class InfoSection {
  const InfoSection({required this.section, required this.body, required this.source, required this.verified});
  final String section;
  final String body;
  final String source;
  final bool verified;

  factory InfoSection.fromJson(Map<String, dynamic> j) => InfoSection(
    section: j['section'] as String,
    body: j['body'] as String,
    source: j['source'] as String,
    verified: (j['verified'] as bool?) ?? false,
  );
}

class ProductDetail {
  const ProductDetail({
    required this.card,
    required this.saleClass,
    this.description,
    required this.images,
    required this.officialInfo,
    required this.favorite,
  });
  final ProductCard card;
  final String saleClass;
  final String? description;
  final List<String> images;
  final List<InfoSection> officialInfo;
  final bool favorite;

  factory ProductDetail.fromJson(Map<String, dynamic> j) => ProductDetail(
    card: ProductCard.fromJson(j['card'] as Map<String, dynamic>),
    saleClass: (j['saleClass'] as String?) ?? 'OTC',
    description: j['description'] as String?,
    images: ((j['images'] as List?) ?? const []).cast<String>(),
    officialInfo: list(j['officialInfo'], InfoSection.fromJson),
    favorite: (j['favorite'] as bool?) ?? false,
  );
}

enum Availability { inStock, lowStock, outOfStock }

class Offer {
  const Offer({
    required this.id,
    required this.productId,
    required this.branchId,
    required this.branchName,
    required this.pharmacyName,
    required this.address,
    required this.price,
    this.oldPrice,
    required this.availability,
    required this.availableQuantity,
    required this.pickupAvailable,
    required this.deliveryAvailable,
    required this.deliveryFee,
    this.freeDeliveryFrom,
    this.etaMin,
    this.etaMax,
    required this.updatedAt,
    required this.demoPharmacy,
  });

  final String id;
  final String productId;
  final String branchId;
  final String branchName;
  final String pharmacyName;
  final String address;
  final double price;
  final double? oldPrice;
  final Availability availability;
  final int availableQuantity;
  final bool pickupAvailable;
  final bool deliveryAvailable;
  final double deliveryFee;
  final double? freeDeliveryFrom;
  final int? etaMin;
  final int? etaMax;
  final DateTime updatedAt;
  final bool demoPharmacy;

  bool get canBuy => availability != Availability.outOfStock;

  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
    id: j['id'] as String,
    productId: j['productId'] as String,
    branchId: j['branchId'] as String,
    branchName: j['branchName'] as String,
    pharmacyName: j['pharmacyName'] as String,
    address: (j['address'] as String?) ?? '',
    price: dbl(j['price']),
    oldPrice: dblOrNull(j['oldPrice']),
    availability: switch (j['availability']) {
      'OUT_OF_STOCK' => Availability.outOfStock,
      'LOW_STOCK' => Availability.lowStock,
      _ => Availability.inStock,
    },
    availableQuantity: intOr(j['availableQuantity']),
    pickupAvailable: (j['pickupAvailable'] as bool?) ?? false,
    deliveryAvailable: (j['deliveryAvailable'] as bool?) ?? false,
    deliveryFee: dbl(j['deliveryFee']),
    freeDeliveryFrom: dblOrNull(j['freeDeliveryFrom']),
    etaMin: (j['etaMinMinutes'] as num?)?.toInt(),
    etaMax: (j['etaMaxMinutes'] as num?)?.toInt(),
    updatedAt: date(j['updatedAt']),
    demoPharmacy: (j['demoPharmacy'] as bool?) ?? false,
  );
}

class SearchResult {
  const SearchResult({required this.items, required this.page, required this.totalItems, required this.hasNext, this.manufacturers});
  final List<ProductCard> items;
  final int page;
  final int totalItems;
  final bool hasNext;
  final List<String>? manufacturers;

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
    items: list(j['items'], ProductCard.fromJson),
    page: intOr(j['page']),
    totalItems: intOr(j['totalItems']),
    hasNext: (j['hasNext'] as bool?) ?? false,
    manufacturers: (j['manufacturers'] as List?)?.cast<String>(),
  );
}

class Suggestion {
  const Suggestion(this.text, this.type);
  final String text;
  final String type;
  factory Suggestion.fromJson(Map<String, dynamic> j) => Suggestion(j['text'] as String, j['type'] as String);
}

class PromoBanner {
  const PromoBanner({required this.id, required this.title, this.subtitle, this.discountPercent, this.code});
  final String id;
  final String title;
  final String? subtitle;
  final int? discountPercent;
  final String? code;
  factory PromoBanner.fromJson(Map<String, dynamic> j) => PromoBanner(
    id: j['id'] as String,
    title: j['title'] as String,
    subtitle: j['subtitle'] as String?,
    discountPercent: (j['discountPercent'] as num?)?.toInt(),
    code: j['code'] as String?,
  );
}

class Branch {
  const Branch({
    required this.id,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.name,
    required this.address,
    this.phone,
    this.openingHours,
    required this.pickupAvailable,
    required this.deliveryAvailable,
    required this.deliveryFee,
    this.freeDeliveryFrom,
    this.etaMin,
    this.etaMax,
    this.distanceKm,
    required this.demo,
    required this.licenseVerified,
  });
  final String id;
  final String pharmacyId;
  final String pharmacyName;
  final String name;
  final String address;
  final String? phone;
  final String? openingHours;
  final bool pickupAvailable;
  final bool deliveryAvailable;
  final double deliveryFee;
  final double? freeDeliveryFrom;
  final int? etaMin;
  final int? etaMax;
  final double? distanceKm;
  final bool demo;
  final bool licenseVerified;

  factory Branch.fromJson(Map<String, dynamic> j) => Branch(
    id: j['id'] as String,
    pharmacyId: j['pharmacyId'] as String,
    pharmacyName: j['pharmacyName'] as String,
    name: j['name'] as String,
    address: j['address'] as String,
    phone: j['phone'] as String?,
    openingHours: j['openingHours'] as String?,
    pickupAvailable: (j['pickupAvailable'] as bool?) ?? false,
    deliveryAvailable: (j['deliveryAvailable'] as bool?) ?? false,
    deliveryFee: dbl(j['deliveryFee']),
    freeDeliveryFrom: dblOrNull(j['freeDeliveryFrom']),
    etaMin: (j['etaMinMinutes'] as num?)?.toInt(),
    etaMax: (j['etaMaxMinutes'] as num?)?.toInt(),
    distanceKm: dblOrNull(j['distanceKm']),
    demo: (j['demo'] as bool?) ?? false,
    licenseVerified: (j['licenseVerified'] as bool?) ?? false,
  );
}

class RuntimeConfig {
  const RuntimeConfig({
    required this.demoMode,
    required this.demoOtp,
    required this.onlinePaymentAvailable,
    required this.onlinePaymentIsDemo,
    required this.supportPhone,
    required this.maxPrescriptionFiles,
    required this.maxPrescriptionFileBytes,
  });
  final bool demoMode;
  final bool demoOtp;
  final bool onlinePaymentAvailable;
  final bool onlinePaymentIsDemo;
  final String supportPhone;
  final int maxPrescriptionFiles;
  final int maxPrescriptionFileBytes;

  static const fallback = RuntimeConfig(
    demoMode: false,
    demoOtp: false,
    onlinePaymentAvailable: false,
    onlinePaymentIsDemo: false,
    supportPhone: '',
    maxPrescriptionFiles: 6,
    maxPrescriptionFileBytes: 10 * 1024 * 1024,
  );

  factory RuntimeConfig.fromJson(Map<String, dynamic> j) => RuntimeConfig(
    demoMode: (j['demoMode'] as bool?) ?? false,
    demoOtp: (j['demoOtp'] as bool?) ?? false,
    onlinePaymentAvailable: (j['onlinePaymentAvailable'] as bool?) ?? false,
    onlinePaymentIsDemo: (j['onlinePaymentIsDemo'] as bool?) ?? false,
    supportPhone: (j['supportPhone'] as String?) ?? '',
    maxPrescriptionFiles: intOr(j['maxPrescriptionFiles'], 6),
    maxPrescriptionFileBytes: intOr(j['maxPrescriptionFileBytes'], 10 * 1024 * 1024),
  );
}
