import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:provider/provider.dart';

class AthleteKeyInsert extends StatefulWidget {
  const AthleteKeyInsert({super.key});

  @override
  State<AthleteKeyInsert> createState() => _AthleteKeyInsertState();
}

class _AthleteKeyInsertState extends State<AthleteKeyInsert> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> athleteKey = {};
  bool isValidKey = false;

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final athleteKeyProvider = Provider.of<AthleteKeyProvider>(context, listen: true);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: localAppTheme['anchorColors']['primaryColor'])),
                child: Center(
                  child: Image.asset('images/AtheleteArea.jpg', fit: BoxFit.cover, height: double.infinity, alignment: const Alignment(0.3, 0.5)),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header2(header: 'Claim your access Key:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 20),
                          header3(header: 'Please provide your email and key in the respective fields below.', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Email',
                            //initialValue: appUser['name'] ?? '',
                            errorMessage: 'Please enter your Email',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteKey['athleteEmail'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FormInputField(
                            label: 'Enter Key',
                            //initialValue: appUser['surname'] ?? '',
                            errorMessage: 'Please enter your Key',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteKey['athleteKey'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Key';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            height: 50,
                            child: elevatedButton(
                              label: 'SUBMIT',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    // Validate the key
                                    isValidKey = await athleteKeyProvider.isAthleteKeyValid(athleteKey['athleteEmail'], athleteKey['athleteKey']);
                                    if (!isValidKey) {
                                      snackbar(context: context, header: 'Invalid Key or Email. Please try again or request a new key.');
                                      //return;
                                    } else {
                                      // If valid, insert the key
                                      internalStatusProvider.setAthleteKey(athleteKey);
                                    }
                                  } catch (e) {
                                    snackbar(context: context, header: e.toString());
                                    print('Error inserting athlete key: $e');
                                  }
                                }
                              },
                              backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                              labelColor: localAppTheme['anchorColors']['secondaryColor'],
                              leadingIcon: Icons.check_circle,
                              trailingIcon: null,
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
