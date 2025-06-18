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
Widget pageHeader({required BuildContext context, required String topText, required String bottomText}) {
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
                textStyle: TextStyle(fontSize: localAppTheme['bodySize'] * 2, fontWeight: FontWeight.bold, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
            ),
            header1(header: topText, context: context, color: localAppTheme['anchorColors']['secondaryColor']),
            header1(header: bottomText, context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ],
        ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageHeaderHeight'] * 0.5,
          width: localAppTheme['pageHeaderHeight'] * 1.75,
          child: Center(child: Image.asset(localAppTheme['logo'], fit: BoxFit.cover)),
        ),
        const SizedBox(width: 50),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Page Footer
Widget pageFooter({required BuildContext context, required String? userRole}) {
  final localAppTheme = ResponsiveTheme(context).theme;

  return Container(
    height: localAppTheme['pageFooterHeight'],
    width: double.infinity,
    color: localAppTheme['anchorColors']['primaryColor'],
    child: Row(
      children: [
        const SizedBox(width: 50),
        header1(header: userRole ?? '', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageFooterHeight'] * 0.4,
          width: localAppTheme['pageFooterHeight'] * 1,
          child: Center(child: Image.asset(localAppTheme['logo'], fit: BoxFit.cover)),
        ),
        const SizedBox(width: 50),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Header 1
Widget header1({required String header, required BuildContext context, required Color? color}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    textAlign: TextAlign.center,
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(fontSize: localAppTheme['header1Size'], color: color, fontWeight: FontWeight.bold),
    ),
  );
}

//------------------------------------------------------------------------
//Header 2
Widget header2({required String header, required BuildContext context, required Color? color}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(fontSize: localAppTheme['header2Size'], color: color, fontWeight: FontWeight.bold),
    ),
  );
}

//------------------------------------------------------------------------
//Header 3
Widget header3({required String header, required BuildContext context, required Color? color}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(fontSize: localAppTheme['header3Size'], color: color, fontWeight: FontWeight.bold),
    ),
  );
}

//------------------------------------------------------------------------
//Body
Widget body({required String header, required Color? color, required BuildContext context}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(fontSize: localAppTheme['bodySize'], color: color, fontWeight: FontWeight.normal),
    ),
  );
}

//------------------------------------------------------------------------
//Form Input Field
// ignore: camel_case_types
class FormInputField extends StatefulWidget {
  final String label;
  final String errorMessage;
  final TextEditingController? controller;
  final bool isMultiline;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool showLabel;
  final String? initialValue;
  final bool? enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? backgroundColor;

  const FormInputField({super.key, required this.label, required this.errorMessage, this.controller, required this.isMultiline, required this.isPassword, required this.prefixIcon, required this.suffixIcon, required this.showLabel, this.initialValue, this.enabled, this.validator, this.onChanged, this.backgroundColor});

  @override
  State<FormInputField> createState() => _FormInputFieldState();
}

// ignore: camel_case_types
class _FormInputFieldState extends State<FormInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return TextFormField(
      style: localAppTheme['font'](
        textStyle: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontSize: localAppTheme['bodySize']),
      ),
      autocorrect: true,
      enableSuggestions: true,
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.backgroundColor,
        suffixIcon: widget.isPassword ? IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off), onPressed: _toggleVisibility) : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
        suffixIconColor: localAppTheme['anchorColors']['primaryColor'],
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        prefixIconColor: localAppTheme['anchorColors']['primaryColor'],
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 2)),
        border: OutlineInputBorder(borderSide: BorderSide(color: localAppTheme['anchorColors']['primaryColor'])),
        hintText: !widget.showLabel ? widget.label : null,
        hintStyle: localAppTheme['font'](textStyle: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
        labelText: widget.showLabel ? widget.label : null,
        labelStyle: localAppTheme['font'](
          textStyle: TextStyle(fontSize: localAppTheme['bodySize'], color: localAppTheme['anchorColors']['primaryColor']),
        ),
      ),
      maxLines: widget.isMultiline ? null : 1,
      minLines: widget.isMultiline ? 3 : 1,
      validator: widget.validator,
      initialValue: widget.controller == null ? widget.initialValue : null,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
    );
  }
}

//------------------------------------------------------------------------
//Elevated Button
Widget elevatedButton({required String label, required VoidCallback? onPressed, required Color? backgroundColor, required Color labelColor, required IconData? leadingIcon, required IconData? trailingIcon, required BuildContext context}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: labelColor, width: 3),
        ),
      ),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: leadingIcon == null ? false : true,
          child: Row(
            children: [
              Icon(leadingIcon, color: labelColor),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          label,
          style: localAppTheme['font'](
            textStyle: TextStyle(fontSize: localAppTheme['header3Size'], color: labelColor, fontWeight: FontWeight.bold),
          ),
        ),
        Visibility(
          visible: trailingIcon == null ? false : true,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(trailingIcon, color: labelColor),
            ],
          ),
        ),
      ],
    ),
  );
}

//------------------------------------------------------------------------
//Text Button
Widget textButton({required String label, required VoidCallback? onPressed, required Color? labelColor, required IconData? leadingIcon, required IconData? trailingIcon, required BuildContext context}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return TextButton(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(labelColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: labelColor!, width: 3),
        ),
      ),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: leadingIcon == null ? false : true,
          child: Row(
            children: [
              Icon(leadingIcon, color: labelColor),
              const SizedBox(width: 10),
            ],
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          label,
          style: localAppTheme['font'](
            textStyle: TextStyle(fontSize: localAppTheme['header3Size'], color: labelColor, fontWeight: FontWeight.bold),
          ),
        ),
        Visibility(
          visible: trailingIcon == null ? false : true,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(trailingIcon, color: labelColor),
            ],
          ),
        ),
      ],
    ),
  );
}
