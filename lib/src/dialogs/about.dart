import 'package:arna/arna.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays an [ArnaAboutDialog], which describes the application and provides a button to show licenses for software
/// used by the application.
///
/// The arguments correspond to the properties on [ArnaAboutDialog].
///
/// The licenses shown on the [ArnaLicensePage] are those returned by the [LicenseRegistry] API, which can be used to
/// add more licenses to the list.
///
/// The [context], [useRootNavigator], [routeSettings] and [anchorPoint] arguments are passed to [showArnaDialog], the
/// documentation for which discusses how it is used.
void showArnaAboutDialog({
  required BuildContext context,
  String? applicationName,
  String? applicationVersion,
  Widget? applicationIcon,
  String? applicationLegalese,
  Uri? applicationUri,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool useBlur = true,
}) {
  showArnaPopupDialog<void>(
    context: context,
    title: 'About',
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return ArnaAboutDialog(
        applicationIcon: applicationIcon,
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationUri: applicationUri,
      );
    },
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    useBlur: useBlur,
  );
}

/// An about box. This is a dialog box with the application's icon, name, version number, and copyright, plus a button
/// to show licenses for software used by the application.
///
/// To show an [ArnaAboutDialog], use [showArnaAboutDialog].
///
/// The [ArnaAboutDialog] shown by [showArnaAboutDialog] includes a button that calls [showArnaLicensePage].
///
/// The licenses shown on the [ArnaLicensePage] are those returned by the [LicenseRegistry] API, which can be used to
/// add more licenses to the list.
class ArnaAboutDialog extends StatelessWidget {
  /// Creates an about box.
  const ArnaAboutDialog({
    super.key,
    this.applicationIcon,
    this.applicationName,
    this.applicationVersion,
    this.applicationUri,
  });

  /// The icon of the application.
  final Widget? applicationIcon;

  /// The name of the application.
  final String? applicationName;

  /// The version of this build of the application.
  final String? applicationVersion;

  /// The uri of the application.
  final Uri? applicationUri;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (applicationIcon != null) applicationIcon!,
        if (applicationName != null) ...<Widget>[
          const SizedBox(height: Styles.padding),
          Text(applicationName!, style: ArnaTheme.of(context).textTheme.titleLarge),
          const SizedBox(height: Styles.padding),
        ],
        ArnaList(
          showDividers: true,
          showBackground: true,
          children: <Widget>[
            if (applicationVersion != null)
              ArnaListTile(
                title: 'Version',
                trailing: Text(applicationVersion!, style: ArnaTheme.of(context).textTheme.body),
              ),
            if (applicationUri != null)
              ArnaListTile(
                title: 'Report an Issue',
                trailing: Padding(
                  padding: Styles.horizontal,
                  child: Icon(
                    Icons.launch_outlined,
                    size: Styles.iconSize,
                    color: ArnaDynamicColor.resolve(ArnaColors.iconColor, context),
                  ),
                ),
                onTap: () async => launchUrl(applicationUri!),
              ),
            ArnaListTile(
              title: 'Licenses',
              trailing: Padding(
                padding: Styles.horizontal,
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: Styles.iconSize,
                  color: ArnaDynamicColor.resolve(ArnaColors.iconColor, context),
                ),
              ),
              onTap: () => showArnaLicensePage(context: context),
            ),
          ],
        ),
      ],
    );
  }
}
