import 'package:arna/arna.dart';
import 'package:flutter/rendering.dart' show TextSelectionPoint;

/// Desktop text selection controls.
class _ArnaDesktopTextSelectionControls extends TextSelectionControls {
  /// Desktop has no text selection handles.
  @override
  Size getHandleSize(double textLineHeight) => Size.zero;

  /// Builder for the Arna-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _ArnaDesktopTextSelectionControlsToolbar(
      clipboardStatus: clipboardStatus,
      endpoints: endpoints,
      globalEditableRegion: globalEditableRegion,
      handleCut: canCut(delegate) ? () => handleCut(delegate) : null,
      handleCopy: canCopy(delegate) ? () => handleCopy(delegate) : null,
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : null,
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : null,
      selectionMidpoint: selectionMidpoint,
      lastSecondaryTapDownPosition: lastSecondaryTapDownPosition,
      textLineHeight: textLineHeight,
    );
  }

  /// Builds the text selection handles, but desktop has none.
  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    return const SizedBox.shrink();
  }

  /// Gets the position for the text selection handles, but desktop has none.
  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      Offset.zero;

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    // Allow SelectAll when selection is not collapsed, unless everything has already been selected.
    final TextEditingValue value = delegate.textEditingValue;
    return delegate.selectAllEnabled &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
  }

  @override
  void handleSelectAll(TextSelectionDelegate delegate) {
    super.handleSelectAll(delegate);
    delegate.hideToolbar();
  }
}

/// Text selection controls.
final TextSelectionControls arnaDesktopTextSelectionControls =
    _ArnaDesktopTextSelectionControls();

// Generates the child that's passed into ArnaDesktopTextSelectionToolbar.
class _ArnaDesktopTextSelectionControlsToolbar extends StatefulWidget {
  /// Creates the child that's passed into ArnaDesktopTextSelectionToolbar.
  const _ArnaDesktopTextSelectionControlsToolbar({
    required this.clipboardStatus,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCopy,
    required this.handleCut,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
    required this.lastSecondaryTapDownPosition,
  });

  final ClipboardStatusNotifier? clipboardStatus;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final Offset? lastSecondaryTapDownPosition;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  _ArnaDesktopTextSelectionControlsToolbarState createState() =>
      _ArnaDesktopTextSelectionControlsToolbarState();
}

/// The [State] for an [_ArnaDesktopTextSelectionControlsToolbar].
class _ArnaDesktopTextSelectionControlsToolbarState
    extends State<_ArnaDesktopTextSelectionControlsToolbar> {
  // Inform the widget that the value of clipboardStatus has changed.
  void _onChangedClipboardStatus() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
  }

  @override
  void didUpdateWidget(_ArnaDesktopTextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clipboardStatus != widget.clipboardStatus) {
      oldWidget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
      widget.clipboardStatus?.addListener(_onChangedClipboardStatus);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.clipboardStatus?.removeListener(_onChangedClipboardStatus);
  }

  @override
  Widget build(BuildContext context) {
    // Don't render the menu until the state of the clipboard is known.
    if (widget.handlePaste != null &&
        widget.clipboardStatus?.value == ClipboardStatus.unknown) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final Offset midpointAnchor = Offset(
      (widget.selectionMidpoint.dx - widget.globalEditableRegion.left).clamp(
        mediaQuery.padding.left,
        mediaQuery.size.width - mediaQuery.padding.right,
      ),
      widget.selectionMidpoint.dy - widget.globalEditableRegion.top,
    );

    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> items = <Widget>[];

    void addToolbarButton(IconData icon, String text, VoidCallback onPressed) {
      items.add(
        ArnaTextSelectionToolbarButton(
          icon: icon,
          label: text,
          onPressed: onPressed,
        ),
      );
    }

    if (widget.handleCut != null) {
      addToolbarButton(
        Icons.cut_outlined,
        localizations.cutButtonLabel,
        widget.handleCut!,
      );
    }
    if (widget.handleCopy != null) {
      addToolbarButton(
        Icons.copy_outlined,
        localizations.copyButtonLabel,
        widget.handleCopy!,
      );
    }
    if (widget.handlePaste != null &&
        widget.clipboardStatus?.value == ClipboardStatus.pasteable) {
      addToolbarButton(
        Icons.paste_outlined,
        localizations.pasteButtonLabel,
        widget.handlePaste!,
      );
    }
    if (widget.handleSelectAll != null) {
      addToolbarButton(
        Icons.select_all_outlined,
        localizations.selectAllButtonLabel,
        widget.handleSelectAll!,
      );
    }

    // If there is no option available, build an empty widget.
    if (items.isEmpty) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return _ArnaDesktopTextSelectionToolbar(
      anchor: widget.lastSecondaryTapDownPosition ?? midpointAnchor,
      children: items,
    );
  }
}

/// An Arna-style desktop text selection toolbar.
///
/// Typically displays buttons for text manipulation, e.g. copying and pasting text.
///
/// Tries to position itself as closely as possible to [anchor] while remaining fully on-screen.
///
/// See also:
///
///  * [_ArnaDesktopTextSelectionControls.buildToolbar], where this is used by default to build an Arna-style toolbar.
class _ArnaDesktopTextSelectionToolbar extends StatelessWidget {
  /// Creates an instance of _ArnaDesktopTextSelectionToolbar.
  const _ArnaDesktopTextSelectionToolbar({
    required this.anchor,
    required this.children,
  }) : assert(children.length > 0);

  /// The point at which the toolbar will attempt to position itself as closely as possible.
  final Offset anchor;

  /// {@macro flutter.material.TextSelectionToolbar.children}
  ///
  /// See also:
  ///   * [ArnaTextSelectionToolbarButton], which builds a default Arna-style text selection toolbar button.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double paddingAbove = mediaQuery.padding.top + Styles.padding;
    final Offset localAdjustment = Offset(Styles.padding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Styles.padding,
        paddingAbove,
        Styles.padding,
        Styles.padding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: anchor - localAdjustment,
        ),
        child: ArnaCard(
          child: Wrap(children: children),
        ),
      ),
    );
  }
}
