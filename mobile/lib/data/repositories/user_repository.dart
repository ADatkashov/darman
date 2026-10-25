import '../../core/network/api_client.dart';
import '../models/catalog_models.dart';
import '../models/user_models.dart';

class AddressInput {
  const AddressInput({
    this.label,
    required this.city,
    required this.street,
    required this.house,
    this.apartment,
    this.entrance,
    this.floor,
    this.comment,
    this.makeDefault = false,
  });
  final String? label;
  final String city;
  final String street;
  final String house;
  final String? apartment;
  final String? entrance;
  final String? floor;
  final String? comment;
  final bool makeDefault;
  Map<String, dynamic> toJson() => {
    'label': label,
    'city': city,
    'street': street,
    'house': house,
    'apartment': apartment,
    'entrance': entrance,
    'floor': floor,
    'comment': comment,
    'defaultAddress': makeDefault,
  };
}

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<UserProfile> me() async => UserProfile.fromJson(await _api.getMap('/users/me'));

  Future<UserProfile> update({
    String? fullName,
    String? email,
    String? locale,
    bool? notifyOrders,
    bool? notifyPromotions,
    bool? notifyPrescriptions,
  }) async => UserProfile.fromJson(
    await _api.patchMap(
      '/users/me',
      body: {
        'fullName': ?fullName,
        'email': ?email,
        'locale': ?locale,
        'notifyOrders': ?notifyOrders,
        'notifyPromotions': ?notifyPromotions,
        'notifyPrescriptions': ?notifyPrescriptions,
      },
    ),
  );

  Future<UserProfile> requestDeletion() async => UserProfile.fromJson(await _api.postMap('/users/me/deletion-request'));

  Future<UserProfile> cancelDeletion() async => UserProfile.fromJson(await _api.deleteMap('/users/me/deletion-request'));

  Future<List<Address>> addresses() async =>
      (await _api.getList('/users/me/addresses')).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();

  Future<Address> createAddress(AddressInput a) async => Address.fromJson(await _api.postMap('/users/me/addresses', body: a.toJson()));

  Future<Address> updateAddress(String id, AddressInput a) async =>
      Address.fromJson(await _api.patchMap('/users/me/addresses/$id', body: a.toJson()));

  Future<void> deleteAddress(String id) => _api.deleteVoid('/users/me/addresses/$id');

  Future<List<ProductCard>> favorites() async =>
      (await _api.getList('/users/me/favorites')).map((e) => ProductCard.fromJson(e as Map<String, dynamic>)).toList();

  Future<void> addFavorite(String productId) => _api.putVoid('/users/me/favorites/$productId');

  Future<void> removeFavorite(String productId) => _api.deleteVoid('/users/me/favorites/$productId');

  Future<List<AppNotification>> notifications() async {
    final page = await _api.getMap('/notifications', query: {'size': 50});
    return (page['items'] as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationRead(String id) => _api.postVoid('/notifications/$id/read');
}
