import 'package:intl/intl.dart';

/// Locale-aware KZT formatting: `1 290 ₸` (ru/kk use a non-breaking space group separator, en uses a comma).
String formatMoney(num amount, String localeCode) {
  final locale = localeCode == 'kk' ? 'kk' : localeCode;
  final rounded = (amount * 100).round() / 100;
  final hasFraction = rounded != rounded.roundToDouble();
  final f = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: hasFraction ? 2 : 0);
  return '${f.format(rounded).replaceAll(' ', ' ')} ₸';
}

String formatDate(DateTime d, String locale) => DateFormat.yMMMd(locale).format(d.toLocal());

String formatDateTime(DateTime d, String locale) => DateFormat.yMMMd(locale).add_Hm().format(d.toLocal());

String formatTime(DateTime d, String locale) => DateFormat.Hm(locale).format(d.toLocal());

/// Rounds to 2 decimals to avoid floating point drift in cart arithmetic.
double roundMoney(double v) => (v * 100).round() / 100;
