double dbl(Object? v) => v == null ? 0 : (v as num).toDouble();
double? dblOrNull(Object? v) => v == null ? null : (v as num).toDouble();
int intOr(Object? v, [int d = 0]) => v == null ? d : (v as num).toInt();
DateTime? dateOrNull(Object? v) => v == null ? null : DateTime.parse(v as String).toLocal();
DateTime date(Object? v) => DateTime.parse(v as String).toLocal();
List<T> list<T>(Object? v, T Function(Map<String, dynamic>) f) =>
    v == null ? <T>[] : (v as List).map((e) => f(e as Map<String, dynamic>)).toList();
