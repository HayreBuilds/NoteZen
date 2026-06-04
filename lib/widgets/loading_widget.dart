import 'package:flutter/material.dart';

/// Centered loading spinner shown while data is being fetched.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.label = 'Loading…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF4F46E5),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
