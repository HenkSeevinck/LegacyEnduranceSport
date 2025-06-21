import 'package:flutter/material.dart';

class TrainingBlock extends StatelessWidget {
  const TrainingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Training Block Setup', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
