import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating; // Dikhane ke liye (0.0 se 5.0 tak)
  final int size;
  final bool interactive; // True hone par user tap karke rating de sakta hai
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating.round();

        Widget star = Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size.toDouble(),
        );

        if (interactive) {
          return GestureDetector(
            onTap: () => onRatingChanged?.call(starValue),
            child: star,
          );
        }
        return star;
      }),
    );
  }
}
