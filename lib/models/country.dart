import 'report.dart';

class Country extends Report {
  Country({
    String id = '',
    this.code = '',
    this.name = '',
    this.latitude = 0,
    this.longitude = 0,
    int confirmed = 0,
    int recovered = 0,
    int deaths = 0,
    DateTime? updateTime,
  }) : super(
          id: id,
          confirmed: confirmed,
          recovered: recovered,
          deaths: deaths,
          updateTime: updateTime,
        );

  Country.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['country'],
        latitude = (json['latitude'] as double?) ?? 0,
        longitude = (json['longitude'] as double?) ?? 0,
        super.fromJson(json);

  /// From covid-193 statistics response item (country name, cases, deaths).
  factory Country.fromStatistics(
    Map<String, dynamic> item, {
    required String code,
  }) {
    final cases = item['cases'] as Map<String, dynamic>?;
    final deaths = item['deaths'] as Map<String, dynamic>?;
    int c = 0, r = 0, d = 0;
    if (cases != null) {
      c = (cases['total'] is int)
          ? cases['total'] as int
          : int.tryParse(cases['total']?.toString() ?? '0') ?? 0;
      r = (cases['recovered'] is int)
          ? cases['recovered'] as int
          : int.tryParse(cases['recovered']?.toString() ?? '0') ?? 0;
    }
    if (deaths != null) {
      d = (deaths['total'] is int)
          ? deaths['total'] as int
          : int.tryParse(deaths['total']?.toString() ?? '0') ?? 0;
    }
    final name = (item['country'] as String?) ?? '';
    return Country(
      code: code,
      name: name.replaceAll('-', ' '),
      confirmed: c,
      recovered: r,
      deaths: d,
      id: code,
    );
  }

  String code;
  String name;
  String get flag => 'https://www.countryflags.io/$code/flat/64.png';

  double latitude;
  double longitude;
}
