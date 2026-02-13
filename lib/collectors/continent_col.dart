import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:kovidoverlook/models/continent.dart';
import 'package:kovidoverlook/utils/constant.dart';

abstract class ContinentCollection {
  static List<Continent>? _continents;

  // New API (covid-193)
  static const String _rapidApiHost193 = 'covid-193.p.rapidapi.com';
  static const String _rapidApiKey193 =
      'cdefa2a000msha7de4d5ef789de5p134196jsnccd8548bb766';
  static const String _statisticsUrl =
      'https://covid-193.p.rapidapi.com/statistics';

  static List<Map<String, dynamic>>? _statisticsCache;
  static Future<List<Map<String, dynamic>>>? _statisticsFuture;

  /// Fetches statistics from new API and caches. Returns the response list.
  static Future<List<Map<String, dynamic>>> getStatistics() async {
    if (_statisticsCache != null) return _statisticsCache!;
    _statisticsFuture ??= _fetchStatistics();
    return _statisticsFuture!;
  }

  static Future<List<Map<String, dynamic>>> _fetchStatistics() async {
    final response = await http.get(
      Uri.parse(_statisticsUrl),
      headers: {
        'x-rapidapi-host': _rapidApiHost193,
        'x-rapidapi-key': _rapidApiKey193,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load statistics: ${response.statusCode}');
    }
    final body = json.decode(response.body) as Map<String, dynamic>;
    final list = body['response'] as List<dynamic>?;
    if (list == null) throw Exception('Invalid response: no response array');
    _statisticsCache = list.map((e) => (e as Map<String, dynamic>)).toList();
    return _statisticsCache!;
  }

  /// Clears cache (e.g. for refresh). Next getStatistics() will fetch again.
  static void clearStatisticsCache() {
    _statisticsCache = null;
    _statisticsFuture = null;
  }

  /// Map API continent name to our continent id/code.
  static String? _continentNameToCode(String? name) {
    if (name == null || name.isEmpty) return null;
    final n = name.toLowerCase().replaceAll('-', ' ').trim();
    switch (n) {
      case 'africa':
        return 'AF';
      case 'asia':
        return 'AS';
      case 'europe':
        return 'EU';
      case 'north america':
        return 'NA';
      case 'south america':
        return 'SA';
      case 'oceania':
        return 'OC';
      default:
        return null;
    }
  }

  static int _intFrom(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static List<Continent> getContinents() {
    _continents ??= [
      Continent(
        name: 'WORLD',
        image: 'assets/images/world.jpg',
        id: '*',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'Africa',
        image: 'assets/images/c_af.png',
        id: 'AF',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'Asia',
        image: 'assets/images/c_as.png',
        id: 'AS',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'Europe',
        image: 'assets/images/c_eu.png',
        id: 'EU',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'N.America',
        image: 'assets/images/c_na.png',
        id: 'NA',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'S.America',
        image: 'assets/images/c_sa.png',
        id: 'SA',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
      Continent(
        name: 'Oceania',
        image: 'assets/images/c_oc.png',
        id: 'OC',
        deaths: 0,
        confirmed: 0,
        recovered: 0,
      ),
    ];
    return _continents ?? [];
  }

  static Future<void> initCountryListIntoContinents(
    BuildContext context,
  ) async {
    var jsonData = json.decode(
      await DefaultAssetBundle.of(context).loadString(Constants.jCountryData),
    );
    List documents = jsonData as List;

    for (final data in documents) {
      var continent = getContinentByCode(data['Continent_Code']);

      if (null == continent) continue;
      continent.addCountryCode(data['Two_Letter_Country_Code']);

      final code = data['Two_Letter_Country_Code'] as String?;
      final name = data['Country_Name'] as String?;
      if (code != null && name != null) {
        final n = _normalizeCountryName(name);
        _countryNameToCode[n] = code;
        final beforeComma = name.split(',').first.trim();
        if (beforeComma.isNotEmpty)
          _countryNameToCode[_normalizeCountryName(beforeComma)] = code;
        final inParens = RegExp(r'\(([^)]+)\)').firstMatch(name);
        if (inParens != null) {
          _countryNameToCode[_normalizeCountryName(inParens.group(1)!)] = code;
        }
      }
    }
  }

  static Continent? getContinentByCode(String? code) {
    if (null == code) return getContinents().first;

    return getContinents().firstWhereOrNull((element) => element.code == code);
  }

  static Map<String, String> _countryNameToCode = {};

  static String? getCountryCodeFromName(String? apiCountryName) {
    if (apiCountryName == null || apiCountryName.isEmpty) return null;
    final key = _normalizeCountryName(apiCountryName);
    return _countryNameToCode[key];
  }

  static String _normalizeCountryName(String s) {
    return s
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'[,()]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // --- Old API (covid-19-data) - no longer works ---
  // static Future<Continent> _getTotal() async {
  //   final response = await http.get(
  //     Uri.parse('https://covid-19-data.p.rapidapi.com/totals?format=json'),
  //     headers: {
  //       "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
  //       "x-rapidapi-key": "8abebd2f0dmsh8d365cd4e9c3293p1de7e1jsn2a5113d8ef55",
  //       "useQueryString": "true",
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     return getContinents().first.updateReport(json.decode(response.body)[0]);
  //   } else {
  //     throw Exception('Failed to load album');
  //   }
  // }

  static Future<Continent> _getTotal() async {
    final list = await getStatistics();
    int totalConfirmed = 0, totalRecovered = 0, totalDeaths = 0;
    final totalsByContinent =
        <String, ({int confirmed, int recovered, int deaths})>{};
    for (final e in list) {
      final cases = e['cases'] as Map<String, dynamic>?;
      final deaths = e['deaths'] as Map<String, dynamic>?;
      final c = _intFrom(cases?['total']);
      final r = _intFrom(cases?['recovered']);
      final d = _intFrom(deaths?['total']);
      totalConfirmed += c;
      totalRecovered += r;
      totalDeaths += d;
      final continentCode = _continentNameToCode(e['continent'] as String?);
      if (continentCode != null) {
        final cur = totalsByContinent[continentCode] ??
            (confirmed: 0, recovered: 0, deaths: 0);
        totalsByContinent[continentCode] = (
          confirmed: cur.confirmed + c,
          recovered: cur.recovered + r,
          deaths: cur.deaths + d,
        );
      }
    }
    final world = getContinents().first;
    world.confirmed = totalConfirmed;
    world.recovered = totalRecovered;
    world.deaths = totalDeaths;
    for (final cont in getContinents()) {
      if (cont.id == '*') continue;
      final t = totalsByContinent[cont.id];
      if (t != null) {
        cont.confirmed = t.confirmed;
        cont.recovered = t.recovered;
        cont.deaths = t.deaths;
      }
    }
    return world;
  }

  static Future<Continent> getContinentReport(String? code) async {
    if (null == code || '*' == code) return _getTotal();
    await getStatistics();
    return getContinentByCode(code) ?? getContinents().first;
  }
}
