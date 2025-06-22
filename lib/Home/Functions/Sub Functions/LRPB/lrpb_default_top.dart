import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class LRPBDefaultTop extends StatelessWidget {
  const LRPBDefaultTop({super.key});

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final blocks = internalStatusProvider.longRangePlanBlocks;

    return Row(
      children: List.generate(blocks.length, (index) {
        return Expanded(
          child: GestureDetector(
            //onTap: () => internalStatusProvider.setlrpbTopWidget(blocks[index]['Navigate']),
            onTap: () {
              internalStatusProvider.setlrpbTopWidget(blocks[index]['navigate']);
              internalStatusProvider.setSelectedLongRangePlanBlocks(blocks[index]);
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], borderRadius: BorderRadius.circular(8.0)),
              child: Center(
                child: header1(header: blocks[index]['setting'], context: context, color: localAppTheme['anchorColors']['secondaryColor']),
              ),
            ),
          ),
        );
      }),
    );
  }
}
