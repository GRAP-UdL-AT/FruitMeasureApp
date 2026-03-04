import 'package:flutter/material.dart';

class EmptyListComponent extends StatelessWidget {
  const EmptyListComponent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: color, size: 45),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
