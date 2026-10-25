import 'json_util.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.phone,
    this.fullName,
    this.email,
    required this.locale,
    required this.notifyOrders,
    required this.notifyPromotions,
    required this.notifyPrescriptions,
    this.deletionRequestedAt,
    required this.role,
  });
  final String id;
  final String phone;
  final String? fullName;
  final String? email;
  final String locale;
  final bool notifyOrders;
  final bool notifyPromotions;
  final bool notifyPrescriptions;
  final DateTime? deletionRequestedAt;
  final String role;

  bool get isStaff => role != 'CUSTOMER';

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id'] as String,
    phone: j['phone'] as String,
    fullName: j['fullName'] as String?,
    email: j['email'] as String?,
    locale: (j['locale'] as String?) ?? 'ru',
    notifyOrders: (j['notifyOrders'] as bool?) ?? true,
    notifyPromotions: (j['notifyPromotions'] as bool?) ?? false,
    notifyPrescriptions: (j['notifyPrescriptions'] as bool?) ?? true,
    deletionRequestedAt: dateOrNull(j['deletionRequestedAt']),
    role: (j['role'] as String?) ?? 'CUSTOMER',
  );
}

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh, required this.user});
  final String access;
  final String refresh;
  final UserProfile user;
  factory AuthTokens.fromJson(Map<String, dynamic> j) => AuthTokens(
    access: j['accessToken'] as String,
    refresh: j['refreshToken'] as String,
    user: UserProfile.fromJson(j['user'] as Map<String, dynamic>),
  );
}

class OtpChallenge {
  const OtpChallenge({required this.phone, required this.expiresInSeconds, this.devOtp});
  final String phone;
  final int expiresInSeconds;
  final String? devOtp;
  factory OtpChallenge.fromJson(Map<String, dynamic> j) =>
      OtpChallenge(phone: j['phone'] as String, expiresInSeconds: intOr(j['expiresInSeconds'], 300), devOtp: j['devOtp'] as String?);
}

class Address {
  const Address({
    required this.id,
    this.label,
    required this.city,
    required this.street,
    required this.house,
    this.apartment,
    this.entrance,
    this.floor,
    this.comment,
    required this.defaultAddress,
    required this.formatted,
  });
  final String id;
  final String? label;
  final String city;
  final String street;
  final String house;
  final String? apartment;
  final String? entrance;
  final String? floor;
  final String? comment;
  final bool defaultAddress;
  final String formatted;

  factory Address.fromJson(Map<String, dynamic> j) => Address(
    id: j['id'] as String,
    label: j['label'] as String?,
    city: j['city'] as String,
    street: j['street'] as String,
    house: j['house'] as String,
    apartment: j['apartment'] as String?,
    entrance: j['entrance'] as String?,
    floor: j['floor'] as String?,
    comment: j['comment'] as String?,
    defaultAddress: (j['defaultAddress'] as bool?) ?? false,
    formatted: (j['formatted'] as String?) ?? '',
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.refId,
    required this.read,
    required this.createdAt,
  });
  final String id;
  final String type;
  final String title;
  final String body;
  final String? refId;
  final bool read;
  final DateTime createdAt;
  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'] as String,
    type: j['type'] as String,
    title: j['title'] as String,
    body: j['body'] as String,
    refId: j['refId'] as String?,
    read: (j['read'] as bool?) ?? false,
    createdAt: date(j['createdAt']),
  );
}
