import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
//import 'package:provider/provider.dart';

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
  //final localAppInfo = Provider.of<AppInfo>(context).appInfo;

  return Container(
    height: localAppTheme['pageHeaderHeight'],
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1),
      color: Colors.transparent,
    ),
    child: Row(
      children: [
        const SizedBox(width: 50),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            header1(header: topText, context: context, color: localAppTheme['anchorColors']['primaryColor']),
            header2(header: bottomText, context: context, color: localAppTheme['anchorColors']['secondaryColor']),
          ],
        ),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageHeaderHeight'] * 0.9,
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
    decoration: BoxDecoration(
      border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1),
      color: Colors.transparent,
    ),
    child: Row(
      children: [
        const SizedBox(width: 50),
        header1(header: userRole ?? '', context: context, color: localAppTheme['anchorColors']['secondaryColor']),
        const Expanded(child: SizedBox(width: 50)),
        SizedBox(
          height: localAppTheme['pageFooterHeight'] * 0.9,
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
//CustomHeader 1
Widget customHeader({required String header, required BuildContext context, required Color? color, required fontWeight, required size}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    textAlign: TextAlign.center,
    header,
    style: localAppTheme['font'](
      textStyle: TextStyle(fontSize: size, color: color, fontWeight: fontWeight),
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
Widget body({required String header, required Color? color, required BuildContext context, TextAlign? textAlign}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Text(
    header,
    textAlign: textAlign ?? TextAlign.start,
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
  final bool? readOnly;
  final Color? backgroundColor;

  const FormInputField({
    super.key,
    required this.label,
    this.readOnly,
    required this.errorMessage,
    this.controller,
    required this.isMultiline,
    required this.isPassword,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.showLabel,
    this.initialValue,
    this.enabled,
    this.validator,
    this.onChanged,
    this.backgroundColor,
  });

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

    final decoration = InputDecoration(
      filled: true,
      fillColor: widget.backgroundColor ?? localAppTheme['anchorColors']['secondaryColor'],
      suffixIcon: widget.isPassword
          ? IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off), onPressed: _toggleVisibility)
          : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
      suffixIconColor: localAppTheme['anchorColors']['primaryColor'],
      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
      prefixIconColor: localAppTheme['anchorColors']['primaryColor'],
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 2)),
      border: OutlineInputBorder(borderSide: BorderSide(color: localAppTheme['anchorColors']['primaryColor'])),
      hintText: !widget.showLabel ? widget.label : null,
      hintStyle: localAppTheme['font'](textStyle: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
      labelText: widget.showLabel ? widget.label : null,
      contentPadding: const EdgeInsets.only(bottom: 10, left: 10),
      labelStyle: localAppTheme['font'](
        textStyle: TextStyle(fontSize: localAppTheme['bodySize'], color: localAppTheme['anchorColors']['primaryColor']),
      ),
    );

    // For multiline inputs allow the TextFormField to size itself (no fixed height).
    if (widget.isMultiline) {
      return TextFormField(
        style: localAppTheme['font'](
          textStyle: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontSize: localAppTheme['bodySize']),
        ),
        autocorrect: true,
        enableSuggestions: true,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        readOnly: widget.readOnly ?? false,
        decoration: decoration,
        maxLines: null,
        minLines: 3,
        validator: widget.validator,
        initialValue: widget.controller == null ? widget.initialValue : null,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
      );
    }

    // Single-line inputs allow natural sizing so error messages display below without squishing the input field.
    return TextFormField(
      style: localAppTheme['font'](
        textStyle: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontSize: localAppTheme['bodySize']),
      ),
      autocorrect: true,
      enableSuggestions: true,
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      readOnly: widget.readOnly ?? false,
      decoration: decoration,
      maxLines: 1,
      minLines: 1,
      validator: widget.validator,
      initialValue: widget.controller == null ? widget.initialValue : null,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
    );
  }
}

//------------------------------------------------------------------------
//Elevated Button
Widget elevatedButton({
  required String label,
  required VoidCallback? onPressed,
  required Color? backgroundColor,
  required Color labelColor,
  required IconData? leadingIcon,
  required IconData? trailingIcon,
  required BuildContext context,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return SizedBox(
    height: localAppTheme['formInputFieldHeight'],
    child: ElevatedButton(
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
    ),
  );
}

//------------------------------------------------------------------------
//Text Button
Widget textButton({
  required String label,
  required VoidCallback? onPressed,
  required Color? labelColor,
  required IconData? leadingIcon,
  required IconData? trailingIcon,
  required BuildContext context,
}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return TextButton(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(labelColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(color: labelColor!, width: 1),
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
//Snackbar Widget
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar({required BuildContext context, required String header}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: header2(
          header: header, 
          context: context, 
          color: localAppTheme['anchorColors']['primaryColor'])
        ),
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
    ),
  );
}

//------------------------------------------------------------------------
//Tick Box Widget

Widget tickBox({required String label, required bool value, required ValueChanged<bool?> onChanged, required BuildContext context, required bool? enabled}) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return Row(
    children: [
      Checkbox(value: value, onChanged: enabled == true ? onChanged : null, activeColor: localAppTheme['anchorColors']['primaryColor']),
      body(header: label, color: localAppTheme['anchorColors']['primaryColor'], context: context),
    ],
  );
}

//------------------------------------------------------------------------
//Date Picker Widget
class DatePicker extends StatefulWidget {
  final Color? buttonBackgroundColor;
  final Color buttonLabelColor;
  final String label;
  final bool buttonVisibility;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function(DateTime)? onChanged;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<DateTimeRange>? blockedRanges;
  final bool? enabled;

  const DatePicker({
    super.key,
    this.buttonBackgroundColor,
    this.blockedRanges,
    required this.buttonLabelColor,
    required this.label,
    required this.buttonVisibility,
    required this.initialDate,
    required this.validator,
    required this.controller,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null && widget.controller.text.isEmpty) {
      widget.controller.text = _formatDate(_selectedDate!);
    }
  }

  String _formatDate(DateTime date) => "${date.toLocal()}".split(' ')[0];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime defaultFirstDate = widget.firstDate ?? today;
    final DateTime defaultLastDate = widget.lastDate ?? DateTime(now.year + 100);

    bool isBlocked(DateTime date) {
      if (widget.blockedRanges == null) return false;
      final d = DateTime(date.year, date.month, date.day);
      for (final range in widget.blockedRanges!) {
        final start = DateTime(range.start.year, range.start.month, range.start.day);
        final end = DateTime(range.end.year, range.end.month, range.end.day);
        if (!d.isBefore(start) && !d.isAfter(end)) {
          return true;
        }
      }
      return false;
    }

    DateTime? findFirstUnblocked(DateTime from, DateTime to) {
      DateTime temp = DateTime(from.year, from.month, from.day);
      final end = DateTime(to.year, to.month, to.day);
      while (!temp.isAfter(end)) {
        if (!isBlocked(temp)) return temp;
        temp = temp.add(const Duration(days: 1));
      }
      return null;
    }

    DateTime? initialDate = _selectedDate;

    if (initialDate == null) {
      if (!isBlocked(now) && !now.isBefore(defaultFirstDate) && !now.isAfter(defaultLastDate)) {
        initialDate = now;
      } else {
        initialDate = findFirstUnblocked(now, defaultLastDate);
      }
    } else if (initialDate.isBefore(defaultFirstDate) || initialDate.isAfter(defaultLastDate) || isBlocked(initialDate)) {
      initialDate = findFirstUnblocked(defaultFirstDate, defaultLastDate);
    }

    if (initialDate == null || isBlocked(initialDate) || initialDate.isBefore(defaultFirstDate) || initialDate.isAfter(defaultLastDate)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No selectable dates available.')));
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
      selectableDayPredicate: (date) => !isBlocked(date),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.controller.text = _formatDate(picked);
      });
      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              child: FormInputField(
                label: widget.label,
                errorMessage: '',
                readOnly: true,
                controller: widget.controller,
                isMultiline: false,
                isPassword: false,
                prefixIcon: null,
                suffixIcon: null,
                showLabel: false,
                initialValue: null,
                enabled: widget.enabled ?? true,
                validator: widget.validator,
                onChanged: null,
              ),
            ),
          ),
          if (widget.buttonVisibility && widget.enabled == true)
            Row(
              children: [
                const SizedBox(width: 10),
                iconButton(
                  label: null,
                  backgroundColor: widget.buttonBackgroundColor,
                  iconColor: widget.buttonLabelColor,
                  icon: Icons.calendar_month,
                  size: 30,
                  toolTip: 'Select Date:',
                  context: context,
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

//------------------------------------------------------------------------
//Icon Button
Widget iconButton({
  required String? label,
  required Color? backgroundColor,
  required Color iconColor,
  required IconData icon,
  required double? size,
  required String? toolTip,
  required BuildContext context,
  required Function()? onPressed,
}) {
  return Container(
    decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
    child: IconButton(
      tooltip: toolTip,
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: size),
    ),
  );
}

//------------------------------------------------------------------------
//Color Picker Widget
class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWidget({super.key, required this.initialColor, required this.onColorChanged});

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  void didUpdateWidget(ColorPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor) {
      _currentColor = widget.initialColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    Color textColor = _currentColor == Colors.transparent ? localAppTheme['anchorColors']['primaryColor'] : _currentColor;

    return Center(
      child: ElevatedButton(
        onPressed: () async {
          Color tempColor = _currentColor;
          final Color? pickedColor = await showDialog<Color>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Pick a color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: tempColor,
                    onColorChanged: (color) {
                      tempColor = color;
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                  TextButton(child: const Text('Submit'), onPressed: () => Navigator.of(context).pop(tempColor)),
                ],
              );
            },
          );
          if (pickedColor != null) {
            setState(() {
              _currentColor = pickedColor;
            });
            widget.onColorChanged(pickedColor);
          }
        },
        style: ElevatedButton.styleFrom(foregroundColor: textColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Text('Select Color', style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------
// Searchable Dropdown Widget
class SearchableDropdown extends StatefulWidget {
  final String labelText;
  final String hint;
  final Color dropdownTextColor;
  final bool searchBoxVisable;
  final List<Map<String, dynamic>> dropDownList;
  final String header;
  final dynamic initialValue;
  final Color iconColor;
  final String idField;
  final String displayField;
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final bool isEnabled;
  final Color? backgroundColor;
  final String? Function(Map<String, dynamic>?)? validator;

  const SearchableDropdown({
    super.key,
    required this.labelText,
    required this.hint,
    required this.dropdownTextColor,
    required this.searchBoxVisable,
    required this.dropDownList,
    required this.header,
    this.initialValue,
    this.validator,
    required this.iconColor,
    required this.idField,
    required this.displayField,
    required this.onChanged,
    required this.isEnabled,
    this.backgroundColor,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  Map<String, dynamic>? selectedItem;
  late List<Map<String, dynamic>> filteredItems;
  bool searchBoxVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = List<Map<String, dynamic>>.from(widget.dropDownList);

    if (widget.initialValue != null) {
      selectedItem = widget.dropDownList.firstWhere(
        (item) => item[widget.idField].toString() == widget.initialValue.toString(),
        orElse: () => <String, dynamic>{},
      );
      if (selectedItem!.isEmpty) selectedItem = null;
    }
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        if (widget.initialValue != null) {
          selectedItem = widget.dropDownList.firstWhere(
            (item) => item[widget.idField].toString() == widget.initialValue.toString(),
            orElse: () => <String, dynamic>{},
          );
          if (selectedItem!.isEmpty) selectedItem = null;
        } else {
          selectedItem = null;
        }
      });
    }
  }

  void resetSelectedItem() {
    setState(() {
      if (widget.initialValue != null) {
        selectedItem = widget.dropDownList.firstWhere(
          (item) => item[widget.idField].toString() == widget.initialValue.toString(),
          orElse: () => <String, dynamic>{},
        );
        if (selectedItem!.isEmpty) selectedItem = null;
      } else {
        selectedItem = null;
      }
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = widget.dropDownList.where((item) => item[widget.displayField].toString().toLowerCase().contains(query.toLowerCase())).toList();
      if (!filteredItems.contains(selectedItem)) {
        selectedItem = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localTheme = ResponsiveTheme(context).theme;
    final double fontSize = localTheme['bodySize'];

    return Column(
      children: <Widget>[
        if (widget.searchBoxVisable && searchBoxVisible)
          Column(
            children: [
              FormInputField(
                label: widget.labelText,
                errorMessage: '',
                isMultiline: false,
                backgroundColor: widget.backgroundColor,
                isPassword: false,
                prefixIcon: null,
                suffixIcon: null,
                showLabel: true,
                controller: _searchController,
                onChanged: (value) => _filterItems(value),
              ),
              const SizedBox(height: 10),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: FormField<Map<String, dynamic>>(
                validator: widget.validator,
                initialValue: selectedItem,
                builder: (FormFieldState<Map<String, dynamic>> field) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      labelText: widget.header,
                      labelStyle: TextStyle(fontSize: fontSize),
                      filled: widget.backgroundColor != null,
                      fillColor: widget.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(color: widget.dropdownTextColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(color: widget.isEnabled ? widget.dropdownTextColor : Colors.grey.shade300),
                      ),
                      errorText: field.errorText,
                    ),
                    isEmpty: field.value == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        hint: body(header: widget.hint, color: widget.dropdownTextColor, context: context),
                        value: selectedItem,
                        items: filteredItems.map((item) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: item,
                            child: body(header: item[widget.displayField].toString(), color: widget.dropdownTextColor, context: context),
                          );
                        }).toList(),
                        onChanged: widget.isEnabled
                            ? (newValue) {
                                setState(() {
                                  selectedItem = newValue;
                                });
                                field.didChange(newValue);
                                if (widget.onChanged != null) {
                                  widget.onChanged!(newValue);
                                }
                              }
                            : null,
                      ),
                    ),
                  );
                  // Keep FormField state in sync with our selectedItem when
                  // initialValue changes from the parent.
                },
              ),
            ),
            if (widget.isEnabled && widget.searchBoxVisable)
              iconButton(
                label: null,
                backgroundColor: null,
                iconColor: widget.iconColor,
                icon: Icons.search,
                size: 30,
                toolTip: 'Enable Search:',
                context: context,
                onPressed: () {
                  setState(() {
                    searchBoxVisible = !searchBoxVisible;
                    if (!searchBoxVisible) {
                      _searchController.clear();
                      filteredItems = List<Map<String, dynamic>>.from(widget.dropDownList);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------
// Slider Widget
class SliderBarWidget extends StatefulWidget {
  final double min;
  final double max;
  final int? divisions;
  final double initialValue;
  final String label;
  final ValueChanged<double>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final int? headerFlex;
  final int? sliderFlex;

  const SliderBarWidget({
    super.key,
    required this.min,
    required this.max,
    this.divisions,
    required this.initialValue,
    required this.label,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.headerFlex,
    this.sliderFlex,
  });

  @override
  State<SliderBarWidget> createState() => _SliderBarWidgetState();
}

class _SliderBarWidgetState extends State<SliderBarWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(SliderBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _currentValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: widget.headerFlex ?? 1,
              child: body(header: widget.label, color: localAppTheme['anchorColors']['primaryColor'], context: context),
            ),
            Expanded(
              flex: widget.sliderFlex ?? 1,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _currentValue,
                      min: widget.min,
                      max: widget.max,
                      divisions: widget.divisions,
                      label: _currentValue.toStringAsFixed(1),
                      activeColor: widget.activeColor ?? localAppTheme['anchorColors']['primaryColor'],
                      inactiveColor: widget.inactiveColor ?? localAppTheme['anchorColors']['secondaryColor'],
                      onChanged: (value) {
                        setState(() {
                          _currentValue = value;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(value);
                        }
                      },
                    ),
                  ),
                  body(header: _currentValue.toStringAsFixed(1), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//----------------------------------------------------
// General Popup Dialog
Future<void> showGeneralPopupDialog(BuildContext context, String title, String message) async {
  final localAppTheme = ResponsiveTheme(context).theme;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button to dismiss
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
        title: header3(header: title, context: context, color: localAppTheme['anchorColors']['primaryColor']),
        content: SingleChildScrollView(
          child: body(header: message, color: localAppTheme['anchorColors']['primaryColor'], context: context),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'])),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

//------------------------------------------------------------------------
// App Header Widget
Widget appheader({
  required BuildContext context,
  required bool automaticallyImplyLeading,
  Function? onPressed,
  }) {
  final localAppTheme = ResponsiveTheme(context).theme;
  return SafeArea(
    top: true,
    child: Stack(
      children: [
        Center(child: Image.asset('images/Legacy-Endurance-Logo.png', height: 70, width: 70, fit: BoxFit.contain)),
        if (automaticallyImplyLeading)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: iconButton(
              label: null,
              backgroundColor: null,
              iconColor: localAppTheme['anchorColors']['primaryColor'],
              icon: Icons.arrow_back,
              size: 30,
              toolTip: 'BACK',
              context: context,
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ),
      ],
    ),
  );
}
