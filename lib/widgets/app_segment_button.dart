import 'package:flutter/material.dart';
import 'package:safe_transfer/data/app_value_item.dart';


class AppSegmentedButton extends StatefulWidget {
  final List<AppValueItem> items;
  final AppValueItem? initialValue;
  final void Function(AppValueItem)? onChanged;
  const AppSegmentedButton(
      {super.key,
      required this.items,
      required this.initialValue,
      this.onChanged});

  @override
  State<AppSegmentedButton> createState() => _AppSegmentedButtonState();
}

class _AppSegmentedButtonState extends State<AppSegmentedButton> {
  Set<AppValueItem> _selected = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selected = Set.from({widget.initialValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<AppValueItem>(
        multiSelectionEnabled: false,
        segments: widget.items.map((e) {
          return ButtonSegment(
            value: e,
    
          );
        }).toList(),
        selected: _selected,
        showSelectedIcon: false,
        onSelectionChanged: (items) {
          _selected = items;
          setState(() {});
          widget.onChanged?.call(items.first);
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: Colors.blue,
          backgroundColor: Colors.white,
          fixedSize: const Size(double.infinity, 60),
          minimumSize: const Size(double.infinity,60),
          selectedForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}


