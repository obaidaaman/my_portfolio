import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';

class DescriptionDev extends StatefulWidget {
  const DescriptionDev({super.key});

  @override
  State<DescriptionDev> createState() => _DescriptionDevState();
}

class _DescriptionDevState extends State<DescriptionDev> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 350),
      height: MediaQuery.of(context).size.height / 1.2,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hi, \nI'm Aman Obaid\nA Software Developer Engineer",
                style: TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.whitePrimary),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue // Set the background color here
                          ),
                      onPressed: () {},
                      child: const Text(
                        'Get in touch',
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          ),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: [
                CustomColor.scaffoldBg.withOpacity(0.3),
                CustomColor.scaffoldBg.withOpacity(0.3)
              ]).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Image.asset(
              height: MediaQuery.of(context).size.height / 2.6,
              'assets/samar.jpg',
              width: MediaQuery.of(context).size.width / 2.7,
            ),
          )
        ],
      ),
    );
  }
}
