import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealCircleLogo extends StatefulWidget {
  final double size;
  const MealCircleLogo({super.key, required this.size});

  @override
  State<MealCircleLogo> createState() => _MealCircleLogoState();
}

class _MealCircleLogoState extends State<MealCircleLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _rotation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.stop();
        _controller.value = 0; // reset rotation to straight
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: EdgeInsets.all(widget.size * (12 / 220)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8C673),
            Color(0xFFC79D47),
            Color(0xFF8E6322),
          ],
          stops: [0.1, 0.5, 0.9],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0B5D34),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(widget.size * (10 / 220)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  width: 1.5,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MEAL',
                  style: GoogleFonts.montserrat(
                    fontSize: widget.size * (22 / 220),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: widget.size * (4 / 220)),
                AnimatedBuilder(
                  animation: _rotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotation.value,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.room_service_rounded,
                    size: widget.size * (52 / 220),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: widget.size * (4 / 220)),
                Text(
                  'CIRCLE',
                  style: GoogleFonts.montserrat(
                    fontSize: widget.size * (22 / 220),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
