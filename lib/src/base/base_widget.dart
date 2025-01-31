import 'package:arna/arna.dart';
import 'package:flutter/services.dart';

/// The base widget builder which grants interactive states to widgets.
typedef ArnaBaseWidgetBuilder = Widget Function(
  /// A handle to the location of a widget in the widget tree.
  BuildContext context,

  /// The state when this widget is enabled and can be interacted with.
  bool enabled,

  /// The state when the user drags their mouse cursor over the given widget.
  bool hover,

  /// The state when the user navigates with the keyboard to a given widget.
  bool focused,

  /// The state when the user is actively pressing down on the given widget.
  bool pressed,

  /// The state when this item has been selected.
  bool selected,
);

/// The base [StatefulWidget] class for many other widgets.
///
/// See also:
///
///  * [ArnaButton]
///  * [ArnaIconButton]
///  * [ArnaTextButton]
///  * [ArnaBottomBarItem]
///  * [ArnaMasterItem]
///  * [ArnaSideBarItem]
///  * [ArnaLinkedButtons]
///  * [ArnaCheckBox]
///  * [ArnaRadio]
///  * [ArnaSwitch]
class ArnaBaseWidget extends StatefulWidget {
  /// Creates a base widget.
  const ArnaBaseWidget({
    Key? key,
    required this.builder,
    this.onPressed,
    this.tooltipMessage,
    this.showAnimation = true,
    this.isFocusable = true,
    this.autofocus = false,
    this.cursor = MouseCursor.defer,
    this.semanticLabel,
  }) : super(key: key);

  /// The base builder for widgets.
  final ArnaBaseWidgetBuilder builder;

  /// The callback that is called when a widget is tapped.
  final VoidCallback? onPressed;

  /// The tooltip message of the widget.
  final String? tooltipMessage;

  /// Whether this widget is focusable or not.
  final bool isFocusable;

  /// Whether to show animation or not.
  final bool showAnimation;

  /// Whether this widget should focus itself if nothing else is already
  /// focused.
  final bool autofocus;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  final MouseCursor cursor;

  /// The semantic label of the widget.
  final String? semanticLabel;

  @override
  _ArnaBaseWidgetState createState() => _ArnaBaseWidgetState();
}

class _ArnaBaseWidgetState extends State<ArnaBaseWidget>
    with SingleTickerProviderStateMixin {
  FocusNode? focusNode;
  bool _hover = false;
  bool _focused = false;
  bool _pressed = false;
  // ignore: prefer_final_fields
  bool _selected = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Map<Type, Action<Intent>> _actions;
  late Map<ShortcutActivator, Intent> _shortcuts;

  /// Whether the widget is enabled or disabled. Widgets are disabled by
  /// default.
  /// To enable a widget, set its [onPressed] property to a non-null value.
  bool get isEnabled => widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    if (widget.showAnimation) {
      _controller = AnimationController(
        vsync: this,
        duration: Styles.basicDuration,
        value: 1.0,
        upperBound: 1.0,
        lowerBound: 0.7,
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Styles.basicCurve,
      );
    }
    focusNode = FocusNode(canRequestFocus: isEnabled);
    if (widget.autofocus) focusNode!.requestFocus();
    _actions = {ActivateIntent: CallbackAction(onInvoke: (_) => _handleTap())};
    _shortcuts = const {
      SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    };
  }

  @override
  void didUpdateWidget(ArnaBaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed != oldWidget.onPressed) {
      focusNode!.canRequestFocus = isEnabled;
      if (!isEnabled) _hover = _pressed = false;
    }
  }

  @override
  void dispose() {
    focusNode!.dispose();
    focusNode = null;
    if (widget.showAnimation) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _focused = hasFocus;
      if (!hasFocus) _pressed = false;
    });
  }

  Future<void> _handleTap() async {
    if (isEnabled) {
      setState(() => _pressed = true);
      widget.onPressed!();
      if (widget.showAnimation) {
        _controller.reverse().then((_) => _controller.forward());
      }
      await Future.delayed(Styles.basicDuration);
      if (mounted) setState(() => _pressed = false);
    }
  }

  void _handleTapDown(_) {
    if (!_pressed && mounted) {
      if (widget.showAnimation) _controller.reverse();
      setState(() => _pressed = true);
    }
  }

  void _handleTapUp(_) {
    if (_pressed && mounted) {
      if (widget.showAnimation) _controller.forward();
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (mounted && widget.showAnimation) _controller.forward();
  }

  void _handleHover(hover) {
    if (hover != _hover && mounted) setState(() => _hover = hover);
  }

  void _handleFocus(focus) {
    if (focus != _focused && mounted) setState(() => _focused = focus);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.builder(
      context,
      isEnabled,
      _hover,
      _focused,
      _pressed,
      _selected,
    );
    if (widget.showAnimation) {
      child = ScaleTransition(scale: _animation, child: child);
    }
    return ArnaTooltip(
      message: widget.tooltipMessage,
      child: MergeSemantics(
        child: Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: isEnabled,
          focusable: isEnabled,
          focused: _focused,
          checked: _selected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: _handleTap,
            onLongPressStart: _handleTapDown,
            onLongPressEnd: _handleTapUp,
            onHorizontalDragStart: _handleTapDown,
            onHorizontalDragEnd: _handleTapUp,
            onVerticalDragStart: _handleTapDown,
            onVerticalDragEnd: _handleTapUp,
            child: FocusableActionDetector(
              enabled: isEnabled && widget.isFocusable,
              focusNode: focusNode,
              autofocus: !isEnabled ? false : widget.autofocus,
              mouseCursor: widget.cursor,
              onShowHoverHighlight: _handleHover,
              onShowFocusHighlight: _handleFocus,
              onFocusChange: _handleFocusChange,
              actions: _actions,
              shortcuts: _shortcuts,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
