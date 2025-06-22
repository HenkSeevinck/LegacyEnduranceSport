import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';

class MesoCycleInput extends StatefulWidget {
  const MesoCycleInput({super.key});

  @override
  State<MesoCycleInput> createState() => _MesoCycleInputState();
}

class _MesoCycleInputState extends State<MesoCycleInput> {
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return SingleChildScrollView(
      child: Column(
        children: [
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'RECOVERY:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'ENDURANCE RUN:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'STEADY STATE RUN:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'TEMPO RUN:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'RUNNING INTERVALS:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
          SliderBarWidget(
            headerFlex: 3,
            sliderFlex: 4,
            min: 0,
            max: 20,
            initialValue: 0,
            label: 'TAPER:',
            divisions: 20,
            activeColor: localAppTheme['anchorColors']['primaryColor'],
            onChanged: (value) {
              // Handle slider value change
              print('Slider value changed: $value');
            },
          ),
        ],
      ),
    );
  }
}
