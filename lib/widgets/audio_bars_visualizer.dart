import 'package:flutter/material.dart';

class AudioBarsVisualizer extends StatelessWidget {
  const AudioBarsVisualizer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (index % 2 == 0) ? 40 : 20,  // Simulated bar height
            width: 8,  // Adjusted bar width
            color: const Color(0xFF5364F6),
          ),
        );
      }),
    );
  }
}
