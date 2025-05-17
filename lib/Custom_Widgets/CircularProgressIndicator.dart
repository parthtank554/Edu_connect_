import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double size;
  final List<Color> gradientColors; // Accepts gradient colors for the spinner
  final double strokeWidth;
  final bool showBackgroundCircle;

  const CustomCircularProgressIndicator({
    super.key,
    this.size = 70.0, // Size of the circular progress indicator
    this.gradientColors = const [Colors.blue, Colors.green], // Default gradient
    this.strokeWidth = 6.0, // Thickness of the progress indicator stroke
    this.showBackgroundCircle = true, // Option to show a background circle
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle (optional)
          if (showBackgroundCircle)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200, // Light grey background circle
              ),
            ),
          // Circular Progress Indicator with gradient
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation(
                LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(
                        Rect.fromCircle(center: const Offset(0, 0), radius: 40))
                    as Color?,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
