import 'package:arna/arna.dart';

/// An Arna-styled badge.
class ArnaBadge extends StatelessWidget {
  /// Creates a badge in the Arna style.
  const ArnaBadge({
    Key? key,
    required this.label,
    this.accentColor = ArnaColors.accentColor,
    this.textColor = ArnaColors.color34,
  }) : super(key: key);

  /// The text label of the badge.
  final String label;

  /// The background color of the badge.
  final Color accentColor;

  /// The label color of the badge.
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Styles.small,
      child: AnimatedContainer(
        height: Styles.badgeSize,
        duration: Styles.basicDuration,
        curve: Styles.basicCurve,
        decoration: BoxDecoration(
          borderRadius: Styles.borderRadius,
          color: accentColor,
        ),
        padding: Styles.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                child: Text(
                  label,
                  style: ArnaTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
