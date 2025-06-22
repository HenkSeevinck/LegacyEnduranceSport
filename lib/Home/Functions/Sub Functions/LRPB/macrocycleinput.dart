import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/getfirstandlastdaysoftheweek.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macromesocycleprovider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class MacroCycleInput extends StatefulWidget {
  const MacroCycleInput({super.key});

  @override
  State<MacroCycleInput> createState() => _MacroCycleInputState();
}

class _MacroCycleInputState extends State<MacroCycleInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  Map<String, dynamic> userUnput = {};
  DateTime? weekStartDate;
  Color _selectedColor = Colors.transparent;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: true);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final macroMesoCycleProvider = Provider.of<MacroMesoCycleProvider>(context, listen: true);
    final blockGoals = macroMesoCycleProvider.blockGoals;
    final trainingBlocks = macroMesoCycleProvider.trainingBlocks;
    final trainingFocus = macroMesoCycleProvider.trainingFocus;
    final blockGoalsDateRanges = macroMesoCycleProvider.blockGoalsDateRanges;
    final trainingBlocksDateRanges = macroMesoCycleProvider.trainingBlocksDateRanges;
    final trainingFocusDateRanges = macroMesoCycleProvider.trainingFocusDateRanges;
    final firstDayOfWeek = internalStatusProvider.firstDayOfWeek;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final currentUser = appUserProvider.appUser;
    final planBlockID = internalStatusProvider.selectedLongRangePlanBlocks?['planBlockID'];
    final List<Map<String, dynamic>> listToShow;
    final List<DateTimeRange> datesToShow;
    final focusBlocks = internalStatusProvider.focusBlocks;

    if (planBlockID == 1) {
      listToShow = trainingBlocks;
      datesToShow = trainingBlocksDateRanges;
    } else if (planBlockID == 2) {
      listToShow = blockGoals;
      datesToShow = blockGoalsDateRanges;
    } else if (planBlockID == 3) {
      listToShow = trainingFocus;
      datesToShow = trainingFocusDateRanges;
    } else {
      listToShow = [];
      datesToShow = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: header3(header: internalStatusProvider.selectedLongRangePlanBlocks?['setting'] ?? 'Error', context: context, color: localAppTheme['anchorColors']['primaryColor']),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                      top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: DatePicker(
                                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                                  label: 'Start Date',
                                  buttonVisibility: true,
                                  initialDate: null,
                                  blockedRanges: datesToShow,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Select a start date';
                                    }
                                    return null;
                                  },
                                  controller: _startDateController,
                                  onChanged: (value) {
                                    int weekIndex = getWeekNumber(value, firstDayOfWeek);
                                    final weekStartDate = getWeekStartDate(value.year, weekIndex, firstDayOfWeek);
                                    userUnput['startDate'] = weekStartDate;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: DatePicker(
                                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                                  label: 'End Date',
                                  buttonVisibility: true,
                                  initialDate: null,
                                  blockedRanges: datesToShow,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Select an end date';
                                    }
                                    return null;
                                  },
                                  controller: _endDateController,
                                  onChanged: (value) {
                                    int weekIndex = getWeekNumber(value, firstDayOfWeek);
                                    final weekEndDate = getWeekEndDate(value.year, weekIndex, firstDayOfWeek);
                                    userUnput['endDate'] = weekEndDate;
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              ColorPickerWidget(
                                initialColor: _selectedColor,
                                onColorChanged: (value) {
                                  setState(() {
                                    _selectedColor = value;
                                    userUnput['color'] = value.value;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: planBlockID != 1
                                    ? FormInputField(
                                        label: internalStatusProvider.selectedLongRangePlanBlocks?['setting'] ?? 'Error',
                                        errorMessage: 'Please provide a input',
                                        isMultiline: false,
                                        isPassword: false,
                                        prefixIcon: Icons.flag,
                                        suffixIcon: null,
                                        showLabel: true,
                                        controller: _goalController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please provide a input';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          userUnput['userInput'] = value;
                                        },
                                      )
                                    : SearchableDropdown(
                                        labelText: '',
                                        hint: '${internalStatusProvider.selectedLongRangePlanBlocks?['setting'] ?? 'Error'}',
                                        dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
                                        searchBoxVisable: false,
                                        dropDownList: focusBlocks,
                                        header: '',
                                        iconColor: localAppTheme['anchorColors']['primaryColor'],
                                        idField: 'blockTypeID',
                                        displayField: 'blockType',
                                        onChanged: (value) {
                                          userUnput['userInput'] = value?['blockTypeID'];
                                        },
                                        isEnabled: true,
                                        backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
                                        validator: (value) => value == null ? 'Please select an option' : null,
                                      ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 150,
                                child: elevatedButton(
                                  label: 'SAVE',
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      userUnput['atheleteUID'] = athleteKeyProvider.selectedAthlete['uid'];
                                      userUnput['planBlockID'] = planBlockID;
                                      userUnput['coachUID'] = currentUser['uid'];
                                      try {
                                        await macroMesoCycleProvider.addMacroMesoCycle(userUnput);
                                        snackbar(context: context, header: 'Item added successfully.');
                                        userUnput.clear(); // Clear the blockGoal map after saving
                                      } catch (e) {
                                        snackbar(context: context, header: 'Error: $e');
                                      }
                                      _goalController.clear();
                                      _startDateController.clear();
                                      _endDateController.clear();
                                      setState(() {
                                        _selectedColor = Colors.transparent; // <-- Reset color picker
                                      });
                                    }
                                  },
                                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                                  leadingIcon: Icons.save,
                                  trailingIcon: null,
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      itemCount: listToShow.length,
                      itemBuilder: (BuildContext context, int index) {
                        String header = (planBlockID == 1) ? focusBlocks.firstWhere((block) => block['blockTypeID'] == listToShow[index]['userInput'], orElse: () => {'blockType': 'ERROR'})['blockType'] : listToShow[index]['userInput'].toString();

                        return ListTile(
                          dense: true,
                          minVerticalPadding: 0,
                          contentPadding: EdgeInsets.symmetric(horizontal: 4),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 7,
                                child: body(header: header, color: localAppTheme['anchorColors']['primaryColor'], context: context),
                              ),
                              Expanded(
                                flex: 2,
                                child: body(header: DateFormat('dd-MMM-yyyy').format((listToShow[index]['startDate'] is DateTime) ? listToShow[index]['startDate'] : listToShow[index]['startDate'].toDate()), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                              ),
                              Expanded(
                                flex: 2,
                                child: body(header: DateFormat('dd-MMM-yyyy').format((listToShow[index]['endDate'] is DateTime) ? listToShow[index]['endDate'] : listToShow[index]['endDate'].toDate()), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Color(listToShow[index]['color'] ?? 0x00000000), // Default transparent if not set
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () {},
                                  tooltip: 'Edit',
                                  icon: Icon(Icons.edit, color: localAppTheme['anchorColors']['primaryColor']),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () async {
                                    try {
                                      macroMesoCycleProvider.deleteMacroMesoCycle(listToShow[index]['macroMesoCycleID']);
                                      snackbar(context: context, header: 'Item deleted successfully');
                                    } catch (e) {
                                      snackbar(context: context, header: 'Error: $e');
                                    }
                                  },
                                  icon: Icon(Icons.delete, color: localAppTheme['anchorColors']['primaryColor']),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
