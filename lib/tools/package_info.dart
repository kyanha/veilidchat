import 'package:package_info_plus/package_info_plus.dart';

String packageInfoAppName = '';
String packageInfoPackageName = '';
String packageInfoVersion = '';
String packageInfoBuildNumber = '';

Future<void> initPackageInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  packageInfoAppName = packageInfo.appName;
  packageInfoPackageName = packageInfo.packageName;
  packageInfoVersion = packageInfo.version;
  packageInfoBuildNumber = packageInfo.buildNumber;
}
