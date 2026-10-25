import 'json_util.dart';

enum PrescriptionStatus { draft, submitted, underReview, approved, rejected, expired }

PrescriptionStatus parsePrescriptionStatus(String s) => switch (s) {
  'SUBMITTED' => PrescriptionStatus.submitted,
  'UNDER_REVIEW' => PrescriptionStatus.underReview,
  'APPROVED' => PrescriptionStatus.approved,
  'REJECTED' => PrescriptionStatus.rejected,
  'EXPIRED' => PrescriptionStatus.expired,
  _ => PrescriptionStatus.draft,
};

class PrescriptionFile {
  const PrescriptionFile({required this.id, required this.name, required this.mimeType, required this.sizeBytes});
  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  bool get isPdf => mimeType == 'application/pdf';
  factory PrescriptionFile.fromJson(Map<String, dynamic> j) => PrescriptionFile(
    id: j['id'] as String,
    name: j['originalName'] as String,
    mimeType: j['mimeType'] as String,
    sizeBytes: intOr(j['sizeBytes']),
  );
}

class PrescriptionEvent {
  const PrescriptionEvent({required this.type, this.comment, required this.createdAt});
  final String type;
  final String? comment;
  final DateTime createdAt;
  factory PrescriptionEvent.fromJson(Map<String, dynamic> j) =>
      PrescriptionEvent(type: j['type'] as String, comment: j['comment'] as String?, createdAt: date(j['createdAt']));
}

class Prescription {
  const Prescription({
    required this.id,
    required this.status,
    this.note,
    this.rejectionReason,
    this.submittedAt,
    this.expiresAt,
    required this.createdAt,
    required this.files,
    required this.events,
    required this.usableForOrder,
    required this.demoReview,
  });
  final String id;
  final PrescriptionStatus status;
  final String? note;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final List<PrescriptionFile> files;
  final List<PrescriptionEvent> events;
  final bool usableForOrder;
  final bool demoReview;

  factory Prescription.fromJson(Map<String, dynamic> j) => Prescription(
    id: j['id'] as String,
    status: parsePrescriptionStatus(j['status'] as String),
    note: j['note'] as String?,
    rejectionReason: j['rejectionReason'] as String?,
    submittedAt: dateOrNull(j['submittedAt']),
    expiresAt: dateOrNull(j['expiresAt']),
    createdAt: date(j['createdAt']),
    files: list(j['files'], PrescriptionFile.fromJson),
    events: list(j['events'], PrescriptionEvent.fromJson),
    usableForOrder: (j['usableForOrder'] as bool?) ?? false,
    demoReview: (j['demoReview'] as bool?) ?? false,
  );
}
