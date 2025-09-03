import 'package:flutter/material.dart';

class CustomTabBarViewPhysics extends PageScrollPhysics {
  const CustomTabBarViewPhysics({super.parent});

  @override
  CustomTabBarViewPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarViewPhysics(parent: buildParent(ancestor));
  }


  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final double boostedVelocity = velocity * 10;
    return super.createBallisticSimulation(position, boostedVelocity);
  }

  @override double get minFlingVelocity => 50.0;
  @override double get minFlingDistance => 3.0;


}