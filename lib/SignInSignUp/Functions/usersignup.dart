import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/ProfileSetup/Page/profilesetup.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/SignInSignUp/Providers/firebase_auth_service.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/validators.dart';
import 'package:provider/provider.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({super.key});

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reEnterPasswordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    reEnterPasswordController.dispose();
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
              header1(header: 'SIGN-UP:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
              const SizedBox(height: 20),
              FormInputField(label: 'Enter Email', errorMessage: 'Please enter a valid email address', isMultiline: false, isPassword: false, prefixIcon: Icons.email, suffixIcon: null, showLabel: true, controller: emailController, validator: emailValidator),
              const SizedBox(height: 20),
              FormInputField(label: 'Enter Password', errorMessage: 'Please enter a valid password', isMultiline: false, isPassword: true, prefixIcon: Icons.lock, suffixIcon: Icons.visibility, showLabel: true, controller: passwordController, validator: passwordValidator),
              const SizedBox(height: 20),
              FormInputField(label: 'Re-Enter Password', errorMessage: 'Please enter a valid password', isMultiline: false, isPassword: true, prefixIcon: Icons.lock, suffixIcon: Icons.visibility, showLabel: true, controller: reEnterPasswordController, validator: (value) => reEnterPasswordValidator(value, passwordController.text)),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: elevatedButton(
                  label: 'SIGN-UP',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final userCredential = await _authService.signUp(emailController.text.trim(), passwordController.text, context);
                      if (userCredential != null) {
                        await appUserProvider.createUserRecord(userCredential.user!);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ProfileSetup()));
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  body(header: 'I HAVE AN ACCOUNT?', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                  TextButton(
                    onPressed: () {
                      internalStatusProvider.setSignInSignUpStatus('SignIn');
                    },
                    child: body(header: 'SIGN-IN', color: localAppTheme['utilityColorPair2']['color1'], context: context),
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
