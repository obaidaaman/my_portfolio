import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';

class DescDevMobile extends StatelessWidget {
  const DescDevMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40.0,
        vertical: 30.0,
      ),
      height: screenHeight,
      constraints: const BoxConstraints(
        minHeight: 560.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar img
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: [
                CustomColor.scaffoldBg.withOpacity(0.6),
                CustomColor.scaffoldBg.withOpacity(0.6),
              ]).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              "assets/samar.jpg",
              width: screenWidth / 2,
            ),
          ),
          const SizedBox(height: 30),
          // intro message
          const Text(
            "Hi,\nI'm Aman Obaid\nA Software Developer Engineer",
            style: TextStyle(
              fontSize: 24,
              height: 1.5,
              fontWeight: FontWeight.bold,
              color: CustomColor.whitePrimary,
            ),
          ),
          const SizedBox(height: 15),
          // contact btn
          SizedBox(
            width: 190.0,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Get in touch"),
            ),
          )
        ],
      ),
    );
  }
}
