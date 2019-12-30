import 'package:flutter/material.dart';

class DropdownPreference<T> extends StatefulWidget {
  const DropdownPreference({
    @required this.title,
    this.desc,
    @required this.values,
    @required this.onWrite,
    @required this.onRead,
  });

  final String title;
  final String desc;

  final Map<T, String> values;

  final Function(BuildContext context, dynamic value) onWrite;
  final T Function(BuildContext context) onRead;

  @override
  _DropdownPreferenceState createState() => _DropdownPreferenceState<T>();
}

class _DropdownPreferenceState<T> extends State<DropdownPreference> {
  @override
  Widget build(BuildContext context) {
    final value = widget.onRead(context);

    return ListTile(
      title: Text(widget.title),
      subtitle: widget.desc == null ? null : Text(widget.desc),
      trailing: DropdownButton<T>(
        items: widget.values.keys.map((val) {
          return DropdownMenuItem<T>(
            value: val,
            child: Text(
              widget.values[val],
              textAlign: TextAlign.end,
            ),
          );
        }).toList(),
        onChanged: (newVal) async {
          widget.onWrite(context, newVal);
        },
        value: value,
      ),
    );
  }
}

class TextPreference extends StatefulWidget {
  const TextPreference({
    this.title,
    this.desc,
    this.ignoreTileTap = false,
    this.onWrite,
    this.onRead,
    this.enabled = true,
  });

  final String title;
  final String desc;
  final bool ignoreTileTap;
  final bool enabled;
  final Function(BuildContext context, String value) onWrite;
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
      subtitle: widget.desc == null ? null : Text(widget.desc),
      title: TextField(
        controller: controller,
        onChanged:
            widget.enabled ? (val) => widget.onWrite(context, val) : null,
      ),
    );
  }
}
