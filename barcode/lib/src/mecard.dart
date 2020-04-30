/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:meta/meta.dart';

/// MeCard is a data file similar to vCard but used by NTT DoCoMo in Japan in
/// QR code format for use with Cellular Phones.
/// https://github.com/zxing/zxing/wiki/Barcode-Contents
@immutable
class MeCard {
  /// Create a custom MeCard
  const MeCard({this.type = 'MECARD', this.fields = const <MeTuple>[]});

  /// Create a contact MeCard
  factory MeCard.contact({
    String name,
    String reading,
    String tel,
    List<String> tels,
    String videophone,
    String email,
    List<String> emails,
    String memo,
    DateTime birthday,
    String address,
    String url,
    List<String> urls,
    String nickname,
  }) {
    final fields = <MeTuple>[];

    if (name != null) {
      fields.add(MeTuple('N', name));
    }
    if (reading != null) {
      fields.add(MeTuple('SOUND', reading));
    }
    if (tel != null) {
      fields.add(MeTuple('TEL', tel));
    }
    if (tels != null) {
      for (final tel in tels) {
        fields.add(MeTuple('TEL', tel));
      }
    }
    if (videophone != null) {
      fields.add(MeTuple('TEL-AV', videophone));
    }
    if (email != null) {
      fields.add(MeTuple('EMAIL', email));
    }
    if (emails != null) {
      for (final email in emails) {
        fields.add(MeTuple('EMAIL', email));
      }
    }
    if (memo != null) {
      fields.add(MeTuple('NOTE', memo));
    }
    if (birthday != null) {
      fields.add(MeTuple.date('BDAY', birthday));
    }
    if (address != null) {
      fields.add(MeTuple('ADR', address));
    }
    if (url != null) {
      fields.add(MeTuple('URL', url));
    }
    if (urls != null) {
      for (final url in urls) {
        fields.add(MeTuple('URL', url));
      }
    }
    if (nickname != null) {
      fields.add(MeTuple('NICKNAME', nickname));
    }

    return MeCard(fields: fields);
  }

  /// Create a WIFI MeCard
  /// type can be WEP or WPA
  factory MeCard.wifi({
    @required String ssid,
    String type = 'WPA',
    String password,
    bool hidden = false,
  }) {
    final fields = <MeTuple>[];

    if (ssid != null) {
      fields.add(MeTuple('S', ssid));
    }
    if (password != null && type != null) {
      fields.add(MeTuple('T', type));
      fields.add(MeTuple('P', password));
    }
    if (hidden == true) {
      fields.add(MeTuple.bool('H', true));
    }

    return MeCard(type: 'WIFI', fields: fields);
  }

  /// MeCard type
  final String type;

  /// Fields composing the MeCard
  final List<MeTuple> fields;

  /// Return the MeCard formatted content for this object
  @override
  String toString() {
    final result = StringBuffer();
    result.write(_str(type) + ':');

    for (final field in fields) {
      result.write(_str(field.key) + ':' + _str(field.val) + ';');
    }

    result.write(';');
    return result.toString();
  }

  static String _str(String s) {
    return s.replaceAllMapped(
      RegExp('[;:"]'),
      (match) => r'\' + match.group(0),
    );
  }
}

/// Tuple key/value for MeCard elements
@immutable
class MeTuple {
  /// Create a tuple
  const MeTuple(this.key, this.val);

  /// Create a tuple with a boolean value
  factory MeTuple.bool(String key, bool val) {
    return MeTuple(key, val ? 'true' : 'false');
  }

  /// Create a tuple with a date value
  factory MeTuple.date(String key, DateTime val) {
    final y = '${val.year}'.padLeft(4, '0');
    final m = '${val.month}'.padLeft(2, '0');
    final d = '${val.day}'.padLeft(2, '0');
    return MeTuple(key, '$y$m$d');
  }

  /// Create a tuple with a comma-separated values
  factory MeTuple.sub(String key, Iterable<String> val) {
    final result = StringBuffer();
    for (final v in val) {
      result.write(v.replaceAll(',', r'\,'));
      result.write(',');
    }

    final data = result.toString();
    var p = data.length - 1;
    while (data.codeUnitAt(p) == 0x2c) {
      p--;
    }

    return MeTuple(key, data.substring(0, p + 1));
  }

  /// The tuple key
  final String key;

  /// The tuple value
  final String val;
}
