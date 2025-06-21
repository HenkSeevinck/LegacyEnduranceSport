import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/macromesocycleprovider.dart';
import 'package:provider/provider.dart';

class BlockGoals extends StatefulWidget {
  const BlockGoals({super.key});

  @override
  State<BlockGoals> createState() => _BlockGoalsState();
}

class _BlockGoalsState extends State<BlockGoals> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  Map<String, dynamic> blockGoal = {};

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
    final blockGoalsDateRanges = macroMesoCycleProvider.blockGoalsDateRanges;
    //print('trainingBlocks: $blockGoals');
    print('blockGoalsDateRanges: $blockGoalsDateRanges');
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0)),
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
                            blockedRanges: blockGoalsDateRanges,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a start date';
                              }
                              return null;
                            },
                            controller: _startDateController,
                            onChanged: (value) {
                              blockGoal['startDate'] = value;
                            },
                          ),
                        ),
                        Expanded(
                          child: DatePicker(
                            buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                            label: 'End Date',
                            buttonVisibility: true,
                            initialDate: null,
                            blockedRanges: blockGoalsDateRanges,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an end date';
                              }
                              return null;
                            },
                            controller: _endDateController,
                            onChanged: (value) {
                              blockGoal['endDate'] = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: FormInputField(
                            label: 'Goal',
                            errorMessage: 'Please enter a goal',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: Icons.flag,
                            suffixIcon: null,
                            showLabel: true,
                            controller: _goalController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a goal';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              blockGoal['goal'] = value;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 150,
                          child: elevatedButton(
                            label: 'SAVE',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                blockGoal['atheleteUID'] = athleteKeyProvider.selectedAthlete['uid'];
                                blockGoal['blockTypeID'] = internalStatusProvider.selectedBlockTypeID;
                                try {
                                  macroMesoCycleProvider.addMacroMesoCycle(blockGoal);
                                  snackbar(context: context, header: 'Block Goal Added Successfully');
                                } catch (e) {
                                  snackbar(context: context, header: 'Error: $e');
                                }
                                _goalController.clear();
                                _startDateController.clear();
                                _endDateController.clear();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header3(header: 'BLOCK GOALS:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                Expanded(
                  child: ListView.builder(
                    itemCount: blockGoals.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 7,
                              child: body(header: blockGoals[index]['goal'] ?? 'N/A', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                            ),
                            Expanded(
                              flex: 2,
                              child: body(header: DateFormat('dd-MMM-yyyy').format((blockGoals[index]['startDate'] is DateTime) ? blockGoals[index]['startDate'] : blockGoals[index]['startDate'].toDate()), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                            ),
                            Expanded(
                              flex: 2,
                              child: body(header: DateFormat('dd-MMM-yyyy').format((blockGoals[index]['endDate'] is DateTime) ? blockGoals[index]['endDate'] : blockGoals[index]['endDate'].toDate()), color: localAppTheme['anchorColors']['primaryColor'], context: context),
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
                                    macroMesoCycleProvider.deleteMacroMesoCycle(blockGoals[index]['macroMesoCycleID']);
                                    snackbar(context: context, header: 'Block Goal Deleted Successfully');
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
