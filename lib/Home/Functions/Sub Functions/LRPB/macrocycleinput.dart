import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/Coach/WorkoutCalendar/Functions/getfirstandlastdaysoftheweek.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macrocycleprovider.dart';
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
    final macroMesoCycleProvider = Provider.of<MacroCycleProvider>(context, listen: true);
    final blockGoals = macroMesoCycleProvider.blockGoals;
    final trainingBlocks = macroMesoCycleProvider.trainingBlocks;
    final trainingFocus = macroMesoCycleProvider.trainingFocus;
    final blockGoalsDateRanges = macroMesoCycleProvider.blockGoalsDateRanges;
    final trainingBlocksDateRanges = macroMesoCycleProvider.trainingBlocksDateRanges;
    final trainingFocusDateRanges = macroMesoCycleProvider.trainingFocusDateRanges;
    final firstDayOfWeek = internalStatusProvider.firstDayOfWeek;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final currentUser = appUserProvider.appUser;
    //final planBlockID = internalStatusProvider.selectedLongRangePlanBlocks?['planBlockID'];
    final planBlockID = internalStatusProvider.planBlockID;
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

    String blockPlanSetting = internalStatusProvider.longRangePlanBlocks.firstWhere((block) => block['planBlockID'] == planBlockID, orElse: () => {'setting': 'Error'})['setting'] ?? 'Error';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          color: localAppTheme['anchorColors']['primaryColor'],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  if (planBlockID != 1) {
                    internalStatusProvider.setPlanBlockID(planBlockID - 1);
                  } else {
                    internalStatusProvider.setPlanBlockID(3);
                  }
                  _goalController.clear();
                  _startDateController.clear();
                  _endDateController.clear();
                },
                icon: Icon(Icons.arrow_circle_left_outlined, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
              SizedBox(
                width: 300,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: header3(header: blockPlanSetting, context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (planBlockID != 3) {
                    internalStatusProvider.setPlanBlockID(planBlockID + 1);
                  } else {
                    internalStatusProvider.setPlanBlockID(1);
                  }
                  _goalController.clear();
                  _startDateController.clear();
                  _endDateController.clear();
                },
                icon: Icon(Icons.arrow_circle_right_outlined, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
            ],
          ),
        ),
        Expanded(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                          ),
                          child: header3(header: 'INPUT:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: DatePicker(
                                  buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                                  label: 'START DATE',
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
                                  label: 'END DATE',
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
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Expanded(
                            flex: 4,
                            child: planBlockID != 1
                                ? FormInputField(
                                    label: blockPlanSetting,
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
                                    hint: blockPlanSetting,
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
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: macroMesoCycleProvider.selectedMacroCycle.isEmpty
                              ? SizedBox(
                                  width: double.infinity,
                                  child: elevatedButton(
                                    label: 'SAVE',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        userUnput['atheleteUID'] = athleteKeyProvider.selectedAthlete['uid'];
                                        userUnput['planBlockID'] = planBlockID;
                                        userUnput['coachUID'] = currentUser['uid'];
                                        try {
                                          await macroMesoCycleProvider.addMacroCycle(userUnput);
                                          snackbar(context: context, header: 'Item added successfully.');
                                          userUnput.clear();
                                        } catch (e) {
                                          snackbar(context: context, header: 'Error: $e');
                                        }
                                        _goalController.clear();
                                        _startDateController.clear();
                                        _endDateController.clear();
                                        setState(() {
                                          _selectedColor = Colors.transparent;
                                        });
                                      }
                                    },
                                    backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                    labelColor: localAppTheme['anchorColors']['secondaryColor'],
                                    leadingIcon: Icons.save,
                                    trailingIcon: null,
                                    context: context,
                                  ),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: elevatedButton(
                                        label: 'SAVE',
                                        onPressed: () async {
                                          // Your update logic here
                                        },
                                        backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                        labelColor: localAppTheme['anchorColors']['secondaryColor'],
                                        leadingIcon: Icons.save,
                                        trailingIcon: null,
                                        context: context,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: elevatedButton(
                                        label: 'CANCEL',
                                        onPressed: () async {
                                          // Your cancel logic here
                                        },
                                        backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                        labelColor: localAppTheme['anchorColors']['secondaryColor'],
                                        leadingIcon: Icons.cancel,
                                        trailingIcon: null,
                                        context: context,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
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
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
                        ),
                        child: header3(header: 'Test', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      ),
                      Expanded(
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
                                        onPressed: () {
                                          macroMesoCycleProvider.selectMacroCycleByID(listToShow[index]['macroCycleID']);
                                        },
                                        tooltip: 'Edit',
                                        icon: Icon(Icons.edit, color: localAppTheme['anchorColors']['primaryColor']),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () async {
                                          try {
                                            macroMesoCycleProvider.deleteMacroCycle(listToShow[index]['macroCycleID']);
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
                    ],
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
