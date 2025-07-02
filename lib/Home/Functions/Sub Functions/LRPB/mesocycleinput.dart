import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/Home/Providers/meseocycleprovider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class MesoCycleInput extends StatefulWidget {
  final int weekNumber;
  final int year;

  const MesoCycleInput(this.weekNumber, this.year, {super.key});

  @override
  State<MesoCycleInput> createState() => _MesoCycleInputState();
}

class _MesoCycleInputState extends State<MesoCycleInput> {
  late Map<String, dynamic> _mesoCycle;

  @override
  void initState() {
    super.initState();
    final mesoCycleProvider = Provider.of<MesoCycleProvider>(context, listen: false);
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: false);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);

    final athleteUID = athleteKeyProvider.selectedAthlete['uid'];
    final coachUID = appUserProvider.appUser['uid'];

    // Try to find an existing record for this week and year
    final existingCycles = mesoCycleProvider.mesoCycles.where((cycle) => cycle['weekNumber'] == widget.weekNumber && cycle['year'] == widget.year);

    if (existingCycles.isNotEmpty) {
      // If a record exists, load it
      _mesoCycle = Map<String, dynamic>.from(existingCycles.first);
    } else {
      // Otherwise, create a new template
      _mesoCycle = {'weekNumber': widget.weekNumber, 'year': widget.year, 'athleteUID': athleteUID, 'coachUID': coachUID, 'recovery': 0.0, 'endurance': 0.0, 'steadyState': 0.0, 'tempo': 0.0, 'intervals': 0.0, 'taper': 0.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final mesoCycleProvider = Provider.of<MesoCycleProvider>(context, listen: true); // Listen for updates

    // Determine if a record exists on every build to ensure the UI is always in sync.
    final existingCycles = mesoCycleProvider.mesoCycles.where((cycle) => cycle['weekNumber'] == widget.weekNumber && cycle['year'] == widget.year);
    final isExistingRecord = existingCycles.isNotEmpty;

    // If a record was just created, sync our local state to get the new mesoCycleID.
    if (isExistingRecord && _mesoCycle['mesoCycleID'] == null) {
      _mesoCycle = Map<String, dynamic>.from(existingCycles.first);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['recovery'] ?? 0.0).toDouble(),
              label: 'RECOVERY:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['recovery'] = value;
                });
              },
            ),
            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['endurance'] ?? 0.0).toDouble(),
              label: 'ENDURANCE:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['endurance'] = value;
                });
              },
            ),
            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['steadyState'] ?? 0.0).toDouble(),
              label: 'STEADY STATE:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['steadyState'] = value;
                });
              },
            ),

            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['tempo'] ?? 0.0).toDouble(),
              label: 'TEMPO:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['tempo'] = value;
                });
              },
            ),
            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['intervals'] ?? 0.0).toDouble(),
              label: 'INTERVALS:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['intervals'] = value;
                });
              },
            ),
            SliderBarWidget(
              headerFlex: 3,
              sliderFlex: 4,
              min: 0,
              max: 20,
              initialValue: (_mesoCycle['taper'] ?? 0.0).toDouble(),
              label: 'TAPER:',
              divisions: 20,
              activeColor: localAppTheme['anchorColors']['primaryColor'],
              onChanged: (value) {
                setState(() {
                  _mesoCycle['taper'] = value;
                });
              },
            ),
            SizedBox(
              height: 50,
              child: elevatedButton(
                label: isExistingRecord ? 'UPDATE' : 'SUBMIT',
                onPressed: () async {
                  try {
                    if (isExistingRecord) {
                      await mesoCycleProvider.updateMesoCycle(_mesoCycle['mesoCycleID'], _mesoCycle);
                      snackbar(context: context, header: 'Mesocycle updated successfully');
                    } else {
                      await mesoCycleProvider.addMesoCycle(_mesoCycle);
                      snackbar(context: context, header: 'Mesocycle created successfully');
                    }
                  } catch (e) {
                    snackbar(context: context, header: 'Error: $e');
                    //return;
                  }
                },
                backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                labelColor: localAppTheme['anchorColors']['secondaryColor'],
                leadingIcon: null,
                trailingIcon: null,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
