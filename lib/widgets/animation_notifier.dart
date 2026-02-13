import 'package:flutter/material.dart';

class AnimationNotifier with ChangeNotifier {
  final AnimationController _animationController;
  final Animation _animation;

  AnimationNotifier(this._animationController)
      : _animation = CurvedAnimation(
          curve: Curves.easeOutCubic,
          parent: _animationController,
        ) {
    _animationController.addListener(() {
      notifyListeners();
    });
  }

  double get value => _animation.value;

  void reverse() => _animationController.reverse();
  void forward() => _animationController.forward();
}
