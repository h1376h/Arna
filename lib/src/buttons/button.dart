import 'package:arna/arna.dart';
import 'package:flutter/cupertino.dart';

/// Button types.
enum ButtonType { normal, colored, destructive, suggested }

/// Button sizes.
enum ButtonSize { normal, huge }

/// An Arna-styled button.
class ArnaButton extends StatelessWidget {
  /// Creates a button.
  const ArnaButton({
    Key? key,
    this.label,
    this.icon,
    required this.onPressed,
    this.tooltipMessage,
    this.buttonType = ButtonType.normal,
    this.buttonSize = ButtonSize.normal,
    this.isFocusable = true,
    this.autofocus = false,
    this.hasBorder = true,
    this.accentColor,
    this.cursor = MouseCursor.defer,
    this.semanticLabel,
  }) : super(key: key);

  /// The text label of the button.
  final String? label;

  /// The icon of the button.
  final IconData? icon;

  /// The callback that is called when a button is tapped.
  final VoidCallback? onPressed;

  /// Text that describes the action that will occur when the button is pressed.
  final String? tooltipMessage;

  /// The type of the button.
  final ButtonType buttonType;

  /// The size of the button.
  final ButtonSize buttonSize;

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

  Widget _buildChild(BuildContext context, bool enabled, Color accent) {
    final List<Widget> children = [];
    if (icon != null) {
      Widget iconWidget = Icon(
        icon!,
        size: Styles.iconSize,
        color: ArnaDynamicColor.resolve(
          !enabled
              ? ArnaColors.disabledColor
              : buttonType == ButtonType.normal
                  ? ArnaColors.iconColor
                  : hasBorder
                      ? ArnaDynamicColor.innerColor(
                          accent,
                          ArnaTheme.brightnessOf(context),
                        )
                      : ArnaDynamicColor.matchingColor(
                          ArnaDynamicColor.resolve(
                            ArnaColors.buttonColor,
                            context,
                          ),
                          accent,
                          context,
                        ),
          context,
        ),
      );
      children.add(iconWidget);
      if (label != null) {
        children.add(
          const SizedBox(width: Styles.padding),
        );
      }
    }
    if (label != null) {
      Widget text = Text(
        label!,
        style: ArnaTheme.of(context).textTheme.buttonTextStyle.copyWith(
              color: ArnaDynamicColor.resolve(
                !enabled
                    ? ArnaColors.disabledColor
                    : buttonType == ButtonType.normal
                        ? ArnaColors.primaryTextColor
                        : ArnaDynamicColor.innerColor(
                            accent,
                            ArnaTheme.brightnessOf(context),
                          ),
                context,
              ),
            ),
      );
      Widget labelWidget = Flexible(child: text);
      children.add(labelWidget);
      if (icon != null) {
        children.add(const SizedBox(width: Styles.padding));
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize:
          buttonSize == ButtonSize.huge ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color accent;
    Brightness brightness = ArnaTheme.brightnessOf(context);
    switch (buttonType) {
      case ButtonType.destructive:
        accent = ArnaColors.errorColor;
        break;
      case ButtonType.suggested:
        accent = ArnaColors.accentColor;
        break;
      default:
        accent = accentColor ?? ArnaTheme.of(context).accentColor;
    }

    return Padding(
      padding: Styles.small,
      child: ArnaBaseWidget(
        builder: (context, enabled, hover, focused, pressed, selected) {
          return AnimatedContainer(
            height: (buttonSize == ButtonSize.huge)
                ? Styles.hugeButtonSize
                : Styles.buttonSize,
            duration: Styles.basicDuration,
            curve: Styles.basicCurve,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: Styles.borderRadius,
              border: Border.all(
                width: focused ? Styles.boldBorder : 1,
                color: hasBorder
                    ? ArnaDynamicColor.resolve(
                        buttonType == ButtonType.normal
                            ? !enabled
                                ? ArnaColors.borderColor
                                : focused
                                    ? ArnaDynamicColor.matchingColor(
                                        ArnaDynamicColor.resolve(
                                          ArnaColors.buttonColor,
                                          context,
                                        ),
                                        accent,
                                        context,
                                      )
                                    : ArnaColors.borderColor
                            : !enabled
                                ? ArnaDynamicColor.blend(
                                    ArnaDynamicColor.innerColor(
                                      accent,
                                      brightness,
                                    ),
                                    21,
                                  )
                                : focused
                                    ? ArnaDynamicColor.outerColor(
                                        accent,
                                        true,
                                      )
                                    : ArnaDynamicColor.outerColor(
                                        accent,
                                        hover,
                                      ),
                        context,
                      )
                    : focused
                        ? ArnaColors.borderColor
                        : ArnaDynamicColor.resolve(
                            ArnaColors.buttonColor,
                            context,
                          ).withAlpha(0),
              ),
              color: !enabled
                  ? ArnaDynamicColor.resolve(
                      ArnaColors.backgroundColor,
                      context,
                    )
                  : buttonType == ButtonType.normal || !hasBorder
                      ? focused
                          ? ArnaDynamicColor.blend(
                              selected
                                  ? ArnaDynamicColor.resolve(
                                      ArnaColors.buttonHoverColor,
                                      context,
                                    )
                                  : ArnaDynamicColor.resolve(
                                      ArnaColors.buttonColor,
                                      context,
                                    ),
                              4,
                              ArnaTheme.brightnessOf(context),
                            )
                          : pressed
                              ? ArnaDynamicColor.resolve(
                                  ArnaColors.buttonPressedColor,
                                  context,
                                )
                              : hover
                                  ? ArnaDynamicColor.resolve(
                                      ArnaColors.buttonHoverColor,
                                      context,
                                    )
                                  : hasBorder
                                      ? ArnaDynamicColor.resolve(
                                          ArnaColors.buttonColor,
                                          context,
                                        )
                                      : ArnaDynamicColor.resolve(
                                          ArnaColors.buttonColor,
                                          context,
                                        ).withAlpha(0)
                      : pressed
                          ? ArnaDynamicColor.blend(
                              accent,
                              21,
                              brightness,
                            )
                          : hover
                              ? ArnaDynamicColor.blend(
                                  accent,
                                  12,
                                  brightness,
                                )
                              : focused
                                  ? ArnaDynamicColor.blend(
                                      accent,
                                      18,
                                      brightness,
                                    )
                                  : accent,
            ),
            padding: icon != null
                ? const EdgeInsets.symmetric(horizontal: Styles.padding - 1)
                : Styles.largeHorizontal,
            child: _buildChild(context, enabled, accent),
          );
        },
        onPressed: onPressed,
        tooltipMessage: onPressed != null ? tooltipMessage : null,
        isFocusable: isFocusable,
        autofocus: autofocus,
        cursor: cursor,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
