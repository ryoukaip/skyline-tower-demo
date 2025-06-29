import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double height;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        final textWidth = textPainter.size.width;
        final containerWidth = constraints.maxWidth;

        if (textWidth > containerWidth) {
          // Text overflows, use Marquee
          return SizedBox(
            height: height,
            child: Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
            ),
          );
        } else {
          // Text fits, show normally
          return SizedBox(
            height: height,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: style,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      },
    );
  }
}
