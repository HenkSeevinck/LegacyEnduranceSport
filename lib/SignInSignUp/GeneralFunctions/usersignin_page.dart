//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
//import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
//import 'package:legacyendurancesport/General/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/SubFunctions/usersignin.dart';
import 'package:legacyendurancesport/SignInSignUp/GeneralFunctions/validators.dart';
import 'package:provider/provider.dart';

class UserSignIn extends StatefulWidget {
  final double? width;
  final double? height;
  const UserSignIn({super.key, this.width, this.height});

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //----------------------------------------------------
  // Build method
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header1(header: 'SIGN-IN:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      SizedBox(height: 20),
                      FormInputField(
                        label: 'EMAIL',
                        errorMessage: 'Please enter a valid email address',
                        isMultiline: false,
                        isPassword: false,
                        prefixIcon: Icons.email,
                        suffixIcon: null,
                        showLabel: true,
                        controller: emailController,
                        validator: emailValidator,
                      ),
                      SizedBox(height: 10),
                      FormInputField(
                        label: 'PASSWORD',
                        errorMessage: 'Please enter a valid password',
                        isMultiline: false,
                        isPassword: true,
                        prefixIcon: Icons.lock,
                        suffixIcon: Icons.visibility,
                        showLabel: true,
                        controller: passwordController,
                        validator: passwordValidator,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            body(header: 'FORGOT YOUR PASSWORD?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                            GestureDetector(
                              child: body(header: 'RESET PASSWORD', color: localAppTheme['utilityColorPair2']['color1'], context: context),
                              onTap: () {
                                internalStatusProvider.setSignInSignUpStatus('ResetPassword');
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: elevatedButton(
                          label: 'SIGN-IN',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                await signInUser(
                                  context, 
                                  appUserProvider, 
                                  emailController.text.trim(), 
                                  passwordController.text,
                                );
                              } catch (e) {
                                snackbar(context: context, header: e.toString());
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
                            body(header: 'DONT\'T HAVE AN ACCOUNT?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                            GestureDetector(
                              child: body(header: 'SIGN-UP', color: localAppTheme['utilityColorPair2']['color1'], context: context),
                              onTap: () {
                                internalStatusProvider.setSignInSignUpStatus('SignUp');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
