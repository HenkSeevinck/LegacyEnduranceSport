import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class NewAthlete extends StatefulWidget {
  const NewAthlete({super.key});

  @override
  State<NewAthlete> createState() => _NewathleteState();
}

class _NewathleteState extends State<NewAthlete> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> keyRequest = {};
  String? generatedAthleteKey;

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final appUser = appUserProvider.appUser;
    final athleteKeyRequestProvider = Provider.of<AthleteKeyProvider>(context, listen: true);

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
                  child: Image.asset('images/CoachingArea.jpg', fit: BoxFit.cover, height: double.infinity, alignment: const Alignment(0.3, 0.5)),
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
                          header2(header: 'Generate an access key for your athlete:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          body(header: 'Please add the email which your athlete will log in and a date when the key must expire.', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                          const SizedBox(height: 20),

                          header3(header: 'Athlete Information:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Athlete Email',
                            //initialValue: appUser['name'] ?? '',
                            errorMessage: '',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              keyRequest['athleteEmail'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Athlete Email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          DatePicker(
                            buttonLabelColor: localAppTheme['anchorColors']['primaryColor'],
                            label: 'Key Expiration Date',
                            buttonVisibility: true,
                            initialDate: null,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                            controller: TextEditingController(),
                            onChanged: (value) {
                              keyRequest['keyExpirationDate'] = value;
                            },
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year, DateTime.now().month + 6, DateTime.now().day),
                          ),
                          const SizedBox(height: 20),

                          if (generatedAthleteKey != null)
                            Row(
                              children: [
                                Expanded(
                                  child: FormInputField(
                                    label: 'Athlete Key',
                                    errorMessage: '',
                                    controller: TextEditingController(text: generatedAthleteKey),
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: Icons.copy,
                                    showLabel: true,
                                    enabled: true,
                                    readOnly: true,
                                    onChanged: null,
                                    validator: null,
                                    //backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, color: localAppTheme['anchorColors']['primaryColor']),
                                  tooltip: 'Copy Athlete Key',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: generatedAthleteKey!));
                                    snackbar(context: context, header: 'Athlete Key copied!');
                                  },
                                ),
                              ],
                            ),

                          const SizedBox(height: 40),

                          SizedBox(
                            height: 50,
                            child: elevatedButton(
                              label: 'SUBMIT',
                              onPressed: () async {
                                keyRequest['coachUID'] = appUser['uid'] ?? '';
                                try {
                                  if (_formKey.currentState!.validate()) {
                                    final result = await athleteKeyRequestProvider.createAthleteKey(keyRequest);
                                    if (result == null) {
                                      snackbar(context: context, header: 'Error creating key.');
                                    } else {
                                      final athleteKey = result['athleteKey'] as String;
                                      final isExisting = result['isExisting'] as bool;
                                      snackbar(context: context, header: isExisting ? 'Existing active key: $athleteKey' : 'New key generated: $athleteKey');
                                      setState(() {
                                        generatedAthleteKey = athleteKey;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  snackbar(context: context, header: e.toString());
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
