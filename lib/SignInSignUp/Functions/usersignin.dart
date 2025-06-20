import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:legacyendurancesport/ProfileSetup/Page/profilesetup.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/validators.dart';
import 'package:provider/provider.dart';

class UserSignIn extends StatefulWidget {
  const UserSignIn({super.key});

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header1(header: 'SIGN-IN:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
              const SizedBox(height: 20),
              FormInputField(label: 'Enter Email', errorMessage: 'Please enter a valid email address', isMultiline: false, isPassword: false, prefixIcon: Icons.email, suffixIcon: null, showLabel: true, controller: emailController, validator: emailValidator),
              const SizedBox(height: 20),
              FormInputField(label: 'Enter Password', errorMessage: 'Please enter a valid password', isMultiline: false, isPassword: true, prefixIcon: Icons.lock, suffixIcon: Icons.visibility, showLabel: true, controller: passwordController, validator: passwordValidator),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  body(header: 'FORGOT YOUR PASSWORD?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign-up page
                    },
                    child: body(header: 'RESET PASSWORD', color: localAppTheme['utilityColorPair2']['color1'], context: context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: elevatedButton(
                  label: 'SIGN-IN',
                  onPressed: () async {
                    try {
                      if (_formKey.currentState!.validate()) {
                        final userCredential = await _authService.signIn(emailController.text.trim(), passwordController.text, context);
                        if (userCredential != null) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final record = await appUserProvider.getUserRecord(user.uid);
                            //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ProfileSetup()));
                            if (record?['userRole'] == null || (record?['userRole'] is List && (record?['userRole'] as List).isEmpty)) {
                              // User record exists, but roles is empty, go to RoleSelection
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ProfileSetup()));
                            } else {
                              // User record and roles exist, go to HomePage
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
                            }
                          } else {
                            snackbar(context: context, header: 'User not found.');
                          }
                        }
                      }
                    } catch (e) {
                      snackbar(context: context, header: e.toString());
                    }
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: Icons.login,
                  trailingIcon: null,
                  context: context,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  body(header: 'DONT\'T HAVE AN ACCOUNT?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                  TextButton(
                    onPressed: () {
                      internalStatusProvider.setSignInSignUpStatus('SignUp');
                    },
                    child: body(header: 'SIGN-UP', color: localAppTheme['utilityColorPair2']['color1'], context: context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
