import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/prescription_models.dart';

class UploadFile {
  const UploadFile({required this.name, required this.bytes});
  final String name;
  final List<int> bytes;
}

class PrescriptionRepository {
  PrescriptionRepository(this._api);
  final ApiClient _api;

  Future<List<Prescription>> list() async =>
      (await _api.getList('/prescriptions')).map((e) => Prescription.fromJson(e as Map<String, dynamic>)).toList();

  Future<Prescription> get(String id) async => Prescription.fromJson(await _api.getMap('/prescriptions/$id'));

  Future<Prescription> create(List<UploadFile> files, {String? note, void Function(double progress)? onProgress}) async {
    final form = FormData();
    for (final f in files) {
      form.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes, filename: f.name)));
    }
    if (note != null && note.trim().isNotEmpty) form.fields.add(MapEntry('note', note.trim()));
    return Prescription.fromJson(
      await _api.postMultipart('/prescriptions', form, onProgress: (s, t) => onProgress?.call(t <= 0 ? 0 : s / t)),
    );
  }

  Future<Prescription> submit(String id) async => Prescription.fromJson(await _api.postMap('/prescriptions/$id/submit'));

  Future<void> deleteDraft(String id) => _api.deleteVoid('/prescriptions/$id');

  /// Authenticated download for the in-app preview; files are never reachable through a public URL.
  Future<List<int>> fileBytes(String id, String fileId) => _api.getBytes('/prescriptions/$id/files/$fileId');
}
