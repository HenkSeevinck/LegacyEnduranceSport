import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class UserSignIn extends StatefulWidget {
  const UserSignIn({super.key});

  @override
  State<UserSignIn> createState() => _UserSignInState();
}

class _UserSignInState extends State<UserSignIn> {
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header1(header: 'SIGN-IN:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
            const SizedBox(height: 20),
            FormInputField(label: 'Enter Email', errorMessage: 'Please enter a valid email address', isMultiline: false, isPassword: false, prefixIcon: Icons.email, suffixIcon: null, showLabel: true),
            const SizedBox(height: 20),
            FormInputField(label: 'Enter Password', errorMessage: 'Please enter a valid password', isMultiline: false, isPassword: true, prefixIcon: Icons.lock, suffixIcon: Icons.visibility, showLabel: true),
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
                onPressed: () {
                  // Handle sign-in logic here
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
    );
  }
}
