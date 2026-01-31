import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class AthleteSelectionPopup extends StatefulWidget {
  const AthleteSelectionPopup({super.key});

  @override
  State<AthleteSelectionPopup> createState() => _AthleteSelectionPopupState();
}

class _AthleteSelectionPopupState extends State<AthleteSelectionPopup> {
  bool isLoading = false;
  Map<String, dynamic>? selectedAthlete;

  //-------------------------------------------------------------
  // Submit Button Function
  Future<void> _submitButtonFunction(athleteData) async {
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    
    if (selectedAthlete != null) {
      try {
        setState(() {
          isLoading = true;
        });
        await appUserProvider.addAthleteToCoach(appUser['coachDocID'], selectedAthlete!['uid'], selectedAthlete!['email'], athleteData);
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
        showGeneralPopupDialog(context, 'Success!', 'Athlete added successfully.');
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
        showGeneralPopupDialog(context, 'Error!', 'Failed to add athlete.');
      }
    }
  }

  //-------------------------------------------------------------
  // Cancel Button Function
  Future<void> _cancelButtonFunction() async {
    selectedAthlete = null;
    Navigator.of(context).pop();
  }

  //-------------------------------------------------------------
  // Build Widget
  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: false);
    final appUser = appUserProvider.appUser;
    final String currentUserUID = appUser['uid'];
    final allUsers = appUserProvider.allUsers.where((user) => user['uid'] != currentUserUID).toList();
    final dropdownUsers = allUsers.map((user) => {...user, 'fullName': '${user['name']} ${user['surname']}'}).toList();

    return AlertDialog(
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
      title: header1(header: 'Select Athlete:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: SearchableDropdown(
            labelText: 'Search Athletes:',
            hint: 'Select Athlete',
            dropdownTextColor: localAppTheme['anchorColors']['primaryColor'],
            searchBoxVisable: true,
            dropDownList: dropdownUsers,
            header: '',
            iconColor: localAppTheme['anchorColors']['primaryColor'],
            idField: 'uid',
            displayField: 'fullName',
            onChanged: (value) {
              setState(() {
                selectedAthlete = value;
              });
            },
            isEnabled: true,
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: elevatedButton(
                label: 'CANCEL',
                onPressed: () async {
                  await _cancelButtonFunction();
                },
                backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                labelColor: localAppTheme['anchorColors']['secondaryColor'],
                leadingIcon: null,
                trailingIcon: null,
                context: context,
              ),
            ),
            Expanded(
              child: elevatedButton(
                label: 'SUBMIT',
                onPressed: () async {
                  await _submitButtonFunction(selectedAthlete);
                },
                backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                labelColor: localAppTheme['anchorColors']['secondaryColor'],
                leadingIcon: null,
                trailingIcon: null,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
