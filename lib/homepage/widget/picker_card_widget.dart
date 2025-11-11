import 'package:flutter/material.dart';

class PickerCardWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const PickerCardWidget({
    Key? key,
    required this.title,
    this.onTap
  }) : super(key: key);


  @override
  State<PickerCardWidget> createState() => _PickerCardWidgetState();
}

class _PickerCardWidgetState extends State<PickerCardWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          print("${widget.title} widget box tapped");
        }
      },
      child: Container(
        width: 140,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:  Center(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
