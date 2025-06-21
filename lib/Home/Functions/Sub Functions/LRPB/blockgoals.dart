import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
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
                            validator: (date) {
                              if (date == null) {
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
                            validator: (date) {
                              if (date == null) {
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
                          height: 50,
                          width: 150,
                          child: elevatedButton(
                            label: 'SAVE',
                            onPressed: () {
                              blockGoal['atheleteUID'] = athleteKeyProvider.selectedAthlete['uid'];
                              blockGoal['BlockTypeID'] = internalStatusProvider.selectedBlockTypeID;

                              print('Block Goal: $blockGoal');
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
          child: SizedBox(
            child: Center(
              child: Text('Block Goals Setup', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
