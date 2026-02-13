import 'dart:async';

import 'package:kovidoverlook/collectors/continent_col.dart';
import 'package:kovidoverlook/models/country.dart';
import 'package:logger/logger.dart';

abstract class CountryCollection {
  // --- Old API (covid-19-data) - no longer works ---
  // static Future<Country?> getCountryByCode(String code) async {
  //   var response = await http.get(
  //     Uri.parse(
  //       'https://covid-19-data.p.rapidapi.com/country/code?format=json&code=$code',
  //     ),
  //     headers: {
  //       "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
  //       "x-rapidapi-key": "8abebd2f0dmsh8d365cd4e9c3293p1de7e1jsn2a5113d8ef55",
  //       "useQueryString": "true",
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     try {
  //       return Country.fromJson(json.decode(response.body)[0]);
  //     } catch (e) {
  //       return null;
  //     }
  //   } else {
  //     throw Exception('Failed to load');
  //   }
  // }

  static Stream<List<Country>> getCountriesByContinentStream<T>(
    String code,
  ) async* {
    final list = await ContinentCollection.getStatistics();
    final continent = ContinentCollection.getContinentByCode(code);
    final allowedCodes = continent?.countries;
    final isWorld = code == null || code.isEmpty || code == '*';

    final res = <Country>[];
    for (final item in list) {
      final apiCountry = item['country'] as String?;
      if (apiCountry == null) continue;
      final countryCode =
          ContinentCollection.getCountryCodeFromName(apiCountry);
      if (countryCode == null) continue;
      if (!isWorld &&
          (allowedCodes == null || !allowedCodes.contains(countryCode))) {
        continue;
      }
      res.add(Country.fromStatistics(item, code: countryCode));
    }
    res.sort((a, b) => b.confirmed.compareTo(a.confirmed));
    yield res;
    Logger().i('Done');
  }
}
