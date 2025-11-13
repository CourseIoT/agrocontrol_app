import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatefulWidget {
  final String? message;
  const CustomLoadingIndicator({super.key, this.message});

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _controller,
          child: const Icon(
            Icons.eco_outlined,
            size: 40,
            color: Color(0xFF2E8B57),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
        ]
      ],
    );
  }
}
