import 'package:flutter/material.dart';

class SelectionGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int crossAxisCount;
  final void Function(Map<String, dynamic> item)? onItemTap;

  const SelectionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 4,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, idx) {
        final item = items[idx];
        // return InkWell(
        //   onTap: () => onItemTap?.call(item),
        //   borderRadius: BorderRadius.circular(8),
        //   child: Center(
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         CircleAvatar(child: Icon(item['icon'])),
        //         const SizedBox(height: 4),
        //         Text(
        //           item['label'],
        //           textAlign: TextAlign.center,
        //           style: const TextStyle(fontSize: 12),
        //         ),
        //       ],
        //     ),
        //   ),
        // );
        return InkWell(
          onTap: () => onItemTap?.call(item),
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 100, // Set a fixed height for your grid item
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align to top
              children: [
                CircleAvatar(child: Icon(item['icon'])),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    item['label'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                    overflow:
                        TextOverflow.ellipsis, // Optional: or use maxLines
                    maxLines: 2, // Limit lines if you want
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
