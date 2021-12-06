/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';

/// A dropdown
class DropdownPreference<T> extends StatefulWidget {
  /// Create a dropdown
  const DropdownPreference({
    Key? key,
    required this.title,
    this.desc,
    required this.values,
    required this.onWrite,
    required this.onRead,
  }) : super(key: key);

  /// The title to display
  final String title;

  /// The description
  final String? desc;

  /// The values the user can choose
  final Map<T, String> values;

  /// Called when the value changes
  final Function(BuildContext context, dynamic value) onWrite;

  /// Called to get the current value
  final T Function(BuildContext context) onRead;

  @override
  _DropdownPreferenceState createState() => _DropdownPreferenceState<T>();
}

class _DropdownPreferenceState<T> extends State<DropdownPreference> {
  @override
  Widget build(BuildContext context) {
    final T value = widget.onRead(context);

    return ListTile(
      title: Text(widget.title),
      subtitle: widget.desc == null ? null : Text(widget.desc!),
      trailing: DropdownButton<T>(
        items: widget.values.keys.map<DropdownMenuItem<T>>((dynamic val) {
          return DropdownMenuItem<T>(
            value: val,
            child: Text(
              widget.values[val]!,
              textAlign: TextAlign.end,
            ),
          );
        }).toList()
          ..sort((a, b) =>
              widget.values[a.value]!.compareTo(widget.values[b.value]!)),
        onChanged: (newVal) async {
          widget.onWrite(context, newVal);
        },
        value: value,
      ),
    );
  }
}

/// A text entry setting
class TextPreference extends StatefulWidget {
  /// Create a text entry setting
  const TextPreference({
    Key? key,
    required this.title,
    this.desc,
    this.ignoreTileTap = false,
    required this.onWrite,
    required this.onRead,
    this.enabled = true,
  }) : super(key: key);

  /// The title
  final String title;

  /// The description
  final String? desc;

  /// Ignore user interactions on the title
  final bool ignoreTileTap;

  /// Enable user interactions
  final bool enabled;

  /// Called when the value changes
  final Function(BuildContext context, String value) onWrite;

  /// Called to get the current value
  final String Function(BuildContext context) onRead;

  @override
  _TextPreferenceState createState() => _TextPreferenceState();
}

class _TextPreferenceState extends State<TextPreference> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final value = widget.onRead(context);
    if (controller.text != value) {
      controller.text = value;
    }

    return ListTile(
      leading: Text(widget.title,
          style: widget.enabled
              ? null
              : TextStyle(color: Theme.of(context).disabledColor)),
      subtitle: widget.desc == null ? null : Text(widget.desc!),
      title: TextField(
        controller: controller,
        onChanged:
            widget.enabled ? (val) => widget.onWrite(context, val) : null,
      ),
    );
  }
}
