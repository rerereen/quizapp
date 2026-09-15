import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget labelWidget = Text(label);
    return SizedBox(
      width: double.infinity,
      child: icon == null
          ? ElevatedButton(onPressed: onPressed, child: labelWidget)
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: labelWidget,
            ),
    );
  }
}
