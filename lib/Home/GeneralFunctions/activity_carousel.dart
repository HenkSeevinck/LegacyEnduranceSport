import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/workouts_provider.dart';
import 'dart:async';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:provider/provider.dart';

class ActivityCarousel extends StatefulWidget {
  const ActivityCarousel({super.key});

  @override
  State<ActivityCarousel> createState() => _ActivityCarouselState();
}

class _ActivityCarouselState extends State<ActivityCarousel> {
  late PageController _pageController;
  late Timer _carouselTimer;
  //final int itemCount = 10; // Number of actual items
  final int _initialPage = 5000; // Start at a high page to allow infinite scrolling
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    
    // Start automatic carousel cycling
    _carouselTimer = Timer.periodic(
      const Duration(seconds: 3), // Change slide every 3 seconds
      (timer) {
        if (_pageController.hasClients) {
          final currentPage = _pageController.page;
          final safeCurrentPage = (currentPage != null && currentPage.isFinite)
              ? currentPage.toInt()
              : _initialPage;
          final nextPage = safeCurrentPage + 1;
          
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final workoutsProvider = Provider.of<WorkoutsProvider>(context, listen: true);
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final completedWorkouts = workoutsProvider.completedWorkoutsLast7Days;
    final workoutTypes = internalStatusProvider.workoutTypes;
    
    //print(completedWorkouts);

    if (completedWorkouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
          ),
        ),
        height: 57,
        child: Center(
          child: body(
            header: 'No completed workouts',
            color: localAppTheme['anchorColors']['primaryColor'],
            context: context,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
        ),
      ),
      height: 57,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          // Use modulo to get the actual item index
          final actualIndex = index % completedWorkouts.length;
          final completedworkoutData = completedWorkouts[actualIndex]['completedworkoutData'] ?? {};
          final workoutTypeID = completedworkoutData['type'];
          final workoutIcon = workoutTypes.firstWhere((type) => type['workoutTypeID'] == workoutTypeID, orElse: () => {'icon': Icons.fitness_center})['icon'];
          final athlete = completedWorkouts[actualIndex]['athelete'] ?? {};

          return Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: athlete['profileImageUrl'] != null
                            ? NetworkImage(athlete['profileImageUrl'])
                            : AssetImage('images/PlaceholderUserImage.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      body(
                        header: '${athlete['name']} ${athlete['surname'] ?? 'Unknown Athlete'}', 
                        color: localAppTheme['anchorColors']['primaryColor'], 
                        context: context
                      ),
                      body(
                        header: completedWorkouts[actualIndex]['workoutDate'] != null
                            ? (completedWorkouts[actualIndex]['workoutDate'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                            : 'Unknown Date', 
                        color: localAppTheme['anchorColors']['primaryColor'], 
                        context: context
                      ),
                    ],
                  ),
                  Icon( workoutIcon, color: localAppTheme['anchorColors']['primaryColor']),
                  body(
                    header: completedworkoutData['distance'].toString(), 
                    color: localAppTheme['anchorColors']['primaryColor'], 
                    context: context
                  ),
                  body(
                    header: completedworkoutData['duration'].toString(), 
                    color: localAppTheme['anchorColors']['primaryColor'], 
                    context: context
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}