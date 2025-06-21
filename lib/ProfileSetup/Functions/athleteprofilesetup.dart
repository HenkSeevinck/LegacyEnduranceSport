import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/Home/Providers/athletekeyrequests.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class Athleteprofilesetup extends StatefulWidget {
  const Athleteprofilesetup({super.key});

  @override
  State<Athleteprofilesetup> createState() => _AthleteprofilesetupState();
}

class _AthleteprofilesetupState extends State<Athleteprofilesetup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController facebookHookController = TextEditingController();
  final TextEditingController instagramHookController = TextEditingController();
  final TextEditingController xHookController = TextEditingController();
  final TextEditingController stravaHookController = TextEditingController();
  final TextEditingController youtubeHookController = TextEditingController();
  final TextEditingController ticktokHookController = TextEditingController();
  Map<String, dynamic> athleteProfile = {};
  bool isOtherChecked = false;
  bool isUltraRunningChecked = false;
  bool isRunningChecked = false;
  bool isCyclingChecked = false;
  bool isTriathlonChecked = false;
  bool isSwimingChecked = false;
  bool facebookChecked = false;
  bool instagramChecked = false;
  bool xChecked = false;
  bool stravaChecked = false;
  bool youtubeChecked = false;
  bool ticktokChecked = false;
  Map<String, dynamic> athleteDisciplines = {};
  Map<String, dynamic> athleteSocialMedia = {};
  bool _initialized = false;

  @override
  void dispose() {
    otherController.dispose();
    facebookHookController.dispose();
    instagramHookController.dispose();
    xHookController.dispose();
    stravaHookController.dispose();
    youtubeHookController.dispose();
    ticktokHookController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
      final appUser = appUserProvider.appUser;
      athleteDisciplines = Map<String, dynamic>.from(appUser['athleteDisciplines'] ?? {});
      athleteSocialMedia = Map<String, dynamic>.from(appUser['athleteSocialMedia'] ?? {});
      otherController.text = athleteDisciplines['other'] ?? '';
      facebookHookController.text = athleteSocialMedia['facebookHook'] ?? '';
      instagramHookController.text = athleteSocialMedia['instagramHook'] ?? '';
      xHookController.text = athleteSocialMedia['xHook'] ?? '';
      stravaHookController.text = athleteSocialMedia['stravaHook'] ?? '';
      youtubeHookController.text = athleteSocialMedia['youtubeHook'] ?? '';
      ticktokHookController.text = athleteSocialMedia['tictokHook'] ?? '';
      isOtherChecked = athleteDisciplines['otherBool'] ?? false;
      isUltraRunningChecked = athleteDisciplines['ultraRunningBool'] ?? false;
      isRunningChecked = athleteDisciplines['runningBool'] ?? false;
      isCyclingChecked = athleteDisciplines['cyclingBool'] ?? false;
      isTriathlonChecked = athleteDisciplines['triathlonBool'] ?? false;
      isSwimingChecked = athleteDisciplines['swimingBool'] ?? false;
      facebookChecked = athleteSocialMedia['facebookBool'] ?? false;
      instagramChecked = athleteSocialMedia['instagramBool'] ?? false;
      xChecked = athleteSocialMedia['xBool'] ?? false;
      stravaChecked = athleteSocialMedia['stravaBool'] ?? false;
      youtubeChecked = athleteSocialMedia['youtubeBool'] ?? false;
      ticktokChecked = athleteSocialMedia['ticktokBool'] ?? false;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
    final selectedUserRole = internalStatusProvider.selectedUserRole;
    final user = FirebaseAuth.instance.currentUser;
    final appUser = appUserProvider.appUser;
    final userRole = appUser['userRole'] as List<dynamic>? ?? [];
    final athleteKey = internalStatusProvider.athleteKey;
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
                          header2(header: 'Athlete Profile Setup:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          body(header: 'Please fill in your details to complete your profile setup.', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                          const SizedBox(height: 20),

                          header3(header: 'Personal Information (Required):', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Your Name',
                            initialValue: appUser['name'] ?? '',
                            errorMessage: 'Please enter your Name',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteProfile['name'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FormInputField(
                            label: 'Enter Your Surname',
                            initialValue: appUser['surname'] ?? '',
                            errorMessage: 'Please enter your Surname',
                            isMultiline: false,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteProfile['surname'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Surname';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Disciplines:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          tickBox(
                            label: 'Running',
                            value: isRunningChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                athleteDisciplines['runningBool'] = value;
                                isRunningChecked = value ?? false;
                              });
                            },
                            context: context,
                          ),
                          const SizedBox(height: 20),
                          tickBox(
                            label: 'Ultra Running',
                            value: isUltraRunningChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                athleteDisciplines['ultraRunningBool'] = value;
                                isUltraRunningChecked = value ?? false;
                              });
                            },
                            context: context,
                          ),
                          const SizedBox(height: 20),
                          tickBox(
                            label: 'Cycling',
                            value: isCyclingChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                athleteDisciplines['cyclingBool'] = value;
                                isCyclingChecked = value ?? false;
                              });
                            },
                            context: context,
                          ),
                          const SizedBox(height: 20),
                          tickBox(
                            label: 'Swiming',
                            value: isSwimingChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                athleteDisciplines['swimingBool'] = value;
                                isSwimingChecked = value ?? false;
                              });
                            },
                            context: context,
                          ),
                          const SizedBox(height: 20),
                          tickBox(
                            label: 'Triathlon',
                            value: isTriathlonChecked,
                            onChanged: (bool? value) {
                              athleteDisciplines['triathlonBool'] = value;
                              isTriathlonChecked = value ?? false;
                            },
                            context: context,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'Other',
                                  value: isOtherChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteDisciplines['other'] = null;
                                        otherController.clear();
                                      }
                                      athleteDisciplines['otherBool'] = value;
                                      isOtherChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: isOtherChecked,
                                  child: FormInputField(
                                    label: 'Other',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: Icons.description,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: otherController,
                                    onChanged: (value) {
                                      athleteDisciplines['other'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Athletic Background:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Your Athletic Background',
                            initialValue: appUser['athleticBackground'] ?? '',
                            errorMessage: 'Please enter your athletic background.',
                            isMultiline: true,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteProfile['athleticBackground'] = value;
                            },
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Performance Highlights:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Your Performance Highlights',
                            initialValue: appUser['performanceHighlights'] ?? '',
                            errorMessage: 'Please enter your performance highlights.',
                            isMultiline: true,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              athleteProfile['performanceHighlights'] = value;
                            },
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Social Media:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'Facebook',
                                  value: facebookChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['facebookHook'] = null;
                                        facebookHookController.clear();
                                      }
                                      athleteSocialMedia['facebookBool'] = value;
                                      facebookChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: facebookChecked,
                                  child: FormInputField(
                                    label: 'Facebook Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: facebookHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['facebookHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'Instagram',
                                  value: instagramChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['instagramHook'] = null;
                                        instagramHookController.clear();
                                      }
                                      athleteSocialMedia['instagramBool'] = value;
                                      instagramChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: instagramChecked,
                                  child: FormInputField(
                                    label: 'Instagram Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: instagramHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['instagramHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'X',
                                  value: xChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['xHook'] = null;
                                        xHookController.clear();
                                      }
                                      athleteSocialMedia['xBool'] = value;
                                      xChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: xChecked,
                                  child: FormInputField(
                                    label: 'X Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: xHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['xHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'YouTube',
                                  value: youtubeChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['youtubeHook'] = null;
                                        youtubeHookController.clear();
                                      }
                                      athleteSocialMedia['youtubeBool'] = value;
                                      youtubeChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: youtubeChecked,
                                  child: FormInputField(
                                    label: 'YouTube Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: youtubeHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['youtubeHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'TikTok',
                                  value: ticktokChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['ticktokHook'] = null;
                                        ticktokHookController.clear();
                                      }
                                      athleteSocialMedia['ticktokBool'] = value;
                                      ticktokChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: ticktokChecked,
                                  child: FormInputField(
                                    label: 'TickTok Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: ticktokHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['ticktokHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: tickBox(
                                  label: 'Strava',
                                  value: stravaChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == false) {
                                        athleteSocialMedia['stravaHook'] = null;
                                        stravaHookController.clear();
                                      }
                                      athleteSocialMedia['stravaBool'] = value;
                                      stravaChecked = value ?? false;
                                    });
                                  },
                                  context: context,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Visibility(
                                  visible: stravaChecked,
                                  child: FormInputField(
                                    label: 'Strava Hook',
                                    errorMessage: '',
                                    isMultiline: false,
                                    isPassword: false,
                                    prefixIcon: null,
                                    suffixIcon: null,
                                    showLabel: true,
                                    controller: stravaHookController,
                                    onChanged: (value) {
                                      athleteSocialMedia['stravaHook'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          SizedBox(
                            height: 50,
                            child: elevatedButton(
                              label: 'SUBMIT',
                              onPressed: () async {
                                if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                                  athleteProfile['athleteDisciplines'] = athleteDisciplines;
                                  athleteProfile['athleteSocialMedia'] = athleteSocialMedia;
                                  if (userRole.isEmpty) {
                                    athleteProfile['userRole'] = [selectedUserRole];
                                  } else {
                                    athleteProfile['userRole'] = userRole;
                                  }
                                  try {
                                    await athleteKeyProvider.updateAthleteKeyWithUID(athleteKey?['athleteEmail'], athleteKey?['athleteKey'], user!.uid);
                                    await appUserProvider.updateUserRecord(user, athleteProfile);

                                    snackbar(context: context, header: 'Profile updated successfully!');

                                    if (selectedUserRole != null && selectedUserRole.isNotEmpty) {
                                      internalStatusProvider.setUserRole(null);
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
                                    } else {
                                      internalStatusProvider.setHomeMainContent(null);
                                    }
                                  } catch (e) {
                                    snackbar(context: context, header: 'Error: ${e.toString()}');
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
