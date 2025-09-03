import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page $currentPage of $totalPages"),
          totalPages > 1 ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                label: const Text('Back'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                label: const Text('Next'),
              ),
            ],
          ) : const SizedBox(
            width: 60,
            height: 40,
          ),
        ],
      ),
    );
  }
}