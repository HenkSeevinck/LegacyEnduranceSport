import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:provider/provider.dart';

//------------------------------------------------------------------------
//Application Info Helper
class AppInfo {
  final Map<String, dynamic> appInfo;
  AppInfo(this.appInfo);
}

//------------------------------------------------------------------------
//Page Header
Widget pageHeader({
  required BuildContext context,
  required String topText,
  required String bottomText,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  final localAppInfo = Provider.of<AppInfo>(context).appInfo;

  return Container(
    height: localAppTheme['pageHeaderHeight'],
    width: double.infinity,
    color: localAppTheme['anchorColors']['primaryColor'],
    child: Row(
      children: [
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              localAppInfo['name'],
              style: localAppTheme['font'](
                textStyle: TextStyle(
                  fontSize: localAppTheme['bodySize'] * 2,
                  fontWeight: FontWeight.bold,
                  color: localAppTheme['anchorColors']['secondaryColor'],
                ),
              ),
            ),
            header1(
              header: topText, 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
            header1(
              header: bottomText, 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
          ],
        ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageHeaderHeight'] * 0.5,
          width: localAppTheme['pageHeaderHeight'] * 1.75,
          child: Center(
            child: Image.asset(
              localAppTheme['logo'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 50)
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Page Footer
Widget pageFooter({
  required BuildContext context,
  required String? userRole,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;

  return Container(
    height: localAppTheme['pageFooterHeight'],
    width: double.infinity,
    color: localAppTheme['anchorColors']['primaryColor'],
    child: Row(
      children: [
        const SizedBox(width: 50),
        header1(
              header: userRole ?? '', 
              context: context, 
              color: localAppTheme['anchorColors']['secondaryColor'],
              ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageFooterHeight'] * 0.4,
          width: localAppTheme['pageFooterHeight'] * 1,
          child: Center(
            child: Image.asset(
              localAppTheme['logo'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Header 1
Widget header1({
  required String header,
  required BuildContext context,
  required Color? color,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    textAlign: TextAlign.center,
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header1Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Header 2
Widget header2({
  required String header,
  required BuildContext context,
  required Color? color,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header2Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Header 3
Widget header3({
  required String header,
  required BuildContext context,
  required Color? color,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['header3Size'],
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//------------------------------------------------------------------------
//Body
Widget body({
  required String header,
  required Color? color,
  required BuildContext context,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(
        fontSize: localAppTheme['bodySize'],
        color: color,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}