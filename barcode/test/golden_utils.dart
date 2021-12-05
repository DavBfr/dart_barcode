import 'dart:io';

import 'package:test/test.dart';

final _updateGoldenFlag = Platform.environment['DART_UPDATE_GOLDEN'] == 'true';

Matcher matchesGoldenString(String name) => MatchesGoldenString(name);

class MatchesGoldenString extends Matcher {
  MatchesGoldenString(this.name);

  final String name;

  @override
  Description describe(Description description) {
    return description.add('string matches golden file $name');
  }

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    final goldenFile = File('test/goldens/$name');
    if (_updateGoldenFlag) {
      final directory = goldenFile.parent;
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      goldenFile.writeAsStringSync(item);
      return true;
    } else {
      return goldenFile.readAsStringSync() == item;
    }
  }
}
