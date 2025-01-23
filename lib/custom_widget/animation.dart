// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class SlideAnimationWidget extends StatefulWidget {
  final Widget child;
  final double delay;

  const SlideAnimationWidget({
    Key? key,
    required this.child,
    this.delay = 0.0,
  }) : super(key: key);

  @override
  _SlideAnimationWidgetState createState() => _SlideAnimationWidgetState();
}

class _SlideAnimationWidgetState extends State<SlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Animasyon süresi
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Sağdan başlayacak
      end: Offset.zero, // Normal pozisyona gelecek
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Animasyonu gecikmeli olarak başlat
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()))
        .then((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}
