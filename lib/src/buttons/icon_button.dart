import 'package:arna/arna.dart';

class ArnaIconButton extends StatelessWidget {
  /// Creates an icon button.
  const ArnaIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltipMessage,
    this.buttonType = ButtonType.normal,
    this.isFocusable = true,
    this.autofocus = false,
    this.hasBorder = true,
    this.accentColor,
    this.cursor = MouseCursor.defer,
    this.semanticLabel,
  }) : super(key: key);

  /// The icon of the button.
  final IconData? icon;

  /// The callback that is called when a button is tapped.
  final VoidCallback? onPressed;

  /// Text that describes the action that will occur when the button is pressed.
  final String? tooltipMessage;

  /// The type of the button.
  final ButtonType buttonType;

  /// Whether this button is focusable or not.
  final bool isFocusable;

  /// Whether this button should focus itself if nothing else is already
  /// focused.
  final bool autofocus;

  /// Whether this button has border or not.
  final bool hasBorder;

  /// The color of the button's focused border.
  final Color? accentColor;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// button.
  final MouseCursor cursor;

  /// The semantic label of the button.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ArnaButton(
      icon: icon,
      onPressed: onPressed,
      tooltipMessage: tooltipMessage,
      buttonType: buttonType,
      isFocusable: isFocusable,
      autofocus: autofocus,
      hasBorder: hasBorder,
      accentColor: accentColor,
      cursor: cursor,
      semanticLabel: semanticLabel,
    );
  }
}
