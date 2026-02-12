import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
//import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/SubFunctions/usersignin.dart';
//import 'package:legacyendurancesport/SignInSignUp/Functions/usersignin_page.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/validators.dart';
import 'package:provider/provider.dart';

class UserSignUp extends StatefulWidget {
  final double? width;
  final double? height;
  const UserSignUp({super.key, this.width, this.height});

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reEnterPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  Map<String, String> appUser = {};
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    reEnterPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);

    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : SizedBox(
              width: MediaQuery.of(context).size.width * (widget.width ?? 0.3),
              height: MediaQuery.of(context).size.height * (widget.height ?? 0.6),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header1(header: 'SIGN-UP:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    FormInputField(
                      label: 'Name',
                      errorMessage: 'Please enter a valid name',
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      controller: nameController,
                      onChanged: (value) {
                        appUser['name'] = value;
                      },
                      validator: (value) {
                        return value == null || value.isEmpty ? 'Please enter your name' : null;
                      },
                    ),
                    FormInputField(
                      label: 'Surname',
                      errorMessage: 'Please enter a valid Surname',
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: null,
                      suffixIcon: null,
                      showLabel: true,
                      controller: surnameController,
                      onChanged: (value) {
                        appUser['surname'] = value;
                      },
                      validator: (value) {
                        return value == null || value.isEmpty ? 'Please enter your surname' : null;
                      },
                    ),
                    FormInputField(
                      label: 'Email',
                      errorMessage: 'Please enter a valid email address',
                      isMultiline: false,
                      isPassword: false,
                      prefixIcon: Icons.email,
                      suffixIcon: null,
                      showLabel: true,
                      controller: emailController,
                      validator: emailValidator,
                    ),
                    FormInputField(
                      label: 'Password',
                      errorMessage: 'Please enter a valid password',
                      isMultiline: false,
                      isPassword: true,
                      prefixIcon: Icons.lock,
                      suffixIcon: Icons.visibility,
                      showLabel: true,
                      controller: passwordController,
                      validator: passwordValidator,
                    ),
                    FormInputField(
                      label: 'Re-Enter Password',
                      errorMessage: 'Please enter a valid password',
                      isMultiline: false,
                      isPassword: true,
                      prefixIcon: Icons.lock,
                      suffixIcon: Icons.visibility,
                      showLabel: true,
                      controller: reEnterPasswordController,
                      validator: (value) => reEnterPasswordValidator(value, passwordController.text),
                    ),
                    SizedBox(
                      height: 50,
                      child: elevatedButton(
                        label: 'SIGN-UP',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              final userCredential = await _authService.signUp(
                                emailController.text.trim(), 
                                passwordController.text, 
                                context,
                              );
                              if (userCredential != null) {
                                await appUserProvider.createUserRecord(userCredential.user!, appUser);
                                await signInUser(
                                  context, 
                                  appUserProvider, 
                                  emailController.text.trim(), 
                                  passwordController.text
                                );
                              }
                            } catch (e) {
                              snackbar(
                                context: context, 
                                header: 'Error during sign-up: ${e.toString()}',
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                        labelColor: localAppTheme['anchorColors']['secondaryColor'],
                        leadingIcon: Icons.login,
                        trailingIcon: null,
                        context: context,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          body(header: 'I HAVE AN ACCOUNT?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                          GestureDetector(
                            child: body(header: 'SIGN-IN', color: localAppTheme['utilityColorPair2']['color1'], context: context),
                            onTap: () {
                              internalStatusProvider.setSignInSignUpStatus('SignIn');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
