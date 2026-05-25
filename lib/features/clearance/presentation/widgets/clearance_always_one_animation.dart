import 'package:flutter/material.dart';

/// Static animation at value 1.0 for non-animated arrival bars.
class ClearanceAlwaysOneAnimation extends Animation<double> {
  const ClearanceAlwaysOneAnimation();

  @override
  double get value => 1.0;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.completed;
}
