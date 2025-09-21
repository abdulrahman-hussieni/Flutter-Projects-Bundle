// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ExpandableHotelCard extends StatefulWidget {
  const ExpandableHotelCard({super.key});

  @override
  State<ExpandableHotelCard> createState() => _ExpandableHotelCardState();
}

class _ExpandableHotelCardState extends State<ExpandableHotelCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(
          minHeight: isExpanded ? 320 : 200,
          maxHeight: isExpanded ? 320 : 200,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isExpanded ? 12 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isExpanded ? 12 : 20),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            if (isExpanded)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: const ExpandedHotelDetails(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExpandedHotelDetails extends StatelessWidget {
  const ExpandedHotelDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Grand Hyatt Manila',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) => Icon(
                Icons.star,
                color: Colors.amber[400],
                size: 16,
              )),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Deluxe King Room',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}