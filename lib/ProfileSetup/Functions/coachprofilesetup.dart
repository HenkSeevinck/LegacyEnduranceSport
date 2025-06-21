import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:provider/provider.dart';

class Coachprofilesetup extends StatefulWidget {
  const Coachprofilesetup({super.key});

  @override
  State<Coachprofilesetup> createState() => _CoachprofilesetupState();
}

class _CoachprofilesetupState extends State<Coachprofilesetup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController facebookHookController = TextEditingController();
  final TextEditingController instagramHookController = TextEditingController();
  final TextEditingController xHookController = TextEditingController();
  final TextEditingController stravaHookController = TextEditingController();
  final TextEditingController youtubeHookController = TextEditingController();
  final TextEditingController ticktokHookController = TextEditingController();
  Map<String, dynamic> coachProfile = {};
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
  Map<String, dynamic> coachingDisciplines = {};
  Map<String, dynamic> coachSocialMedia = {};
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
      coachingDisciplines = Map<String, dynamic>.from(appUser['coachingDisciplines'] ?? {});
      coachSocialMedia = Map<String, dynamic>.from(appUser['coachSocialMedia'] ?? {});
      otherController.text = coachingDisciplines['other'] ?? '';
      facebookHookController.text = coachSocialMedia['facebookHook'] ?? '';
      instagramHookController.text = coachSocialMedia['instagramHook'] ?? '';
      xHookController.text = coachSocialMedia['xHook'] ?? '';
      stravaHookController.text = coachSocialMedia['stravaHook'] ?? '';
      youtubeHookController.text = coachSocialMedia['youtubeHook'] ?? '';
      ticktokHookController.text = coachSocialMedia['tictokHook'] ?? '';
      isOtherChecked = coachSocialMedia['otherBool'] ?? false;
      isUltraRunningChecked = coachSocialMedia['ultraRunningBool'] ?? false;
      isRunningChecked = coachSocialMedia['runningBool'] ?? false;
      isCyclingChecked = coachSocialMedia['cyclingBool'] ?? false;
      isTriathlonChecked = coachSocialMedia['triathlonBool'] ?? false;
      isSwimingChecked = coachSocialMedia['swimingBool'] ?? false;
      facebookChecked = coachSocialMedia['facebookBool'] ?? false;
      instagramChecked = coachSocialMedia['instagramBool'] ?? false;
      xChecked = coachSocialMedia['xBool'] ?? false;
      stravaChecked = coachSocialMedia['stravaBool'] ?? false;
      youtubeChecked = coachSocialMedia['youtubeBool'] ?? false;
      ticktokChecked = coachSocialMedia['ticktokBool'] ?? false;
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
                          header2(header: 'Coach Profile Setup:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          body(header: 'Please fill in your coaching details to complete your profile setup.', color: localAppTheme['anchorColors']['primaryColor'], context: context),
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
                              coachProfile['name'] = value;
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
                              coachProfile['surname'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Surname';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Coaching Disciplines:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          tickBox(
                            label: 'Running',
                            value: isRunningChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                coachingDisciplines['runningBool'] = value;
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
                                coachingDisciplines['ultraRunningBool'] = value;
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
                                coachingDisciplines['cyclingBool'] = value;
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
                                coachingDisciplines['swimingBool'] = value;
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
                              coachingDisciplines['triathlonBool'] = value;
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
                                        coachingDisciplines['other'] = null;
                                        otherController.clear();
                                      }
                                      coachingDisciplines['otherBool'] = value;
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
                                      coachingDisciplines['other'] = value;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Coaching Experience:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Your Coaching Experience',
                            initialValue: appUser['experience'] ?? '',
                            errorMessage: 'Please enter your coaching experience',
                            isMultiline: true,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              coachProfile['experience'] = value;
                            },
                          ),
                          const SizedBox(height: 40),

                          header3(header: 'Coaching Qualifications:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                          const SizedBox(height: 10),
                          FormInputField(
                            label: 'Enter Your Coaching Qualifications',
                            initialValue: appUser['qualifications'] ?? '',
                            errorMessage: 'Please enter your coaching qualifications',
                            isMultiline: true,
                            isPassword: false,
                            prefixIcon: null,
                            suffixIcon: null,
                            showLabel: true,
                            onChanged: (value) {
                              coachProfile['qualifications'] = value;
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
                                        coachSocialMedia['facebookHook'] = null;
                                        facebookHookController.clear();
                                      }
                                      coachSocialMedia['facebookBool'] = value;
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
                                      coachSocialMedia['facebookHook'] = value;
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
                                        coachSocialMedia['instagramHook'] = null;
                                        instagramHookController.clear();
                                      }
                                      coachSocialMedia['instagramBool'] = value;
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
                                      coachSocialMedia['instagramHook'] = value;
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
                                        coachSocialMedia['xHook'] = null;
                                        xHookController.clear();
                                      }
                                      coachSocialMedia['xBool'] = value;
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
                                      coachSocialMedia['xHook'] = value;
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
                                        coachSocialMedia['youtubeHook'] = null;
                                        youtubeHookController.clear();
                                      }
                                      coachSocialMedia['youtubeBool'] = value;
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
                                      coachSocialMedia['youtubeHook'] = value;
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
                                        coachSocialMedia['ticktokHook'] = null;
                                        ticktokHookController.clear();
                                      }
                                      coachSocialMedia['ticktokBool'] = value;
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
                                      coachSocialMedia['ticktokHook'] = value;
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
                                        coachSocialMedia['stravaHook'] = null;
                                        stravaHookController.clear();
                                      }
                                      coachSocialMedia['stravaBool'] = value;
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
                                      coachSocialMedia['stravaHook'] = value;
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
                                  coachProfile['coachingDisciplines'] = coachingDisciplines;
                                  coachProfile['coachSocialMedia'] = coachSocialMedia;
                                  if (userRole.isEmpty) {
                                    coachProfile['userRole'] = [selectedUserRole];
                                  } else {
                                    coachProfile['userRole'] = userRole;
                                  }
                                  try {
                                    await appUserProvider.updateUserRecord(user!, coachProfile);
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
