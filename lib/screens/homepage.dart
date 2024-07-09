import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';
import 'package:my_portfolio/constants/size.dart';
import 'package:my_portfolio/utils/social_media_utils.dart';
import 'package:my_portfolio/widgets/contact_section.dart';
import 'package:my_portfolio/widgets/desc_dev_desktop.dart';
import 'package:my_portfolio/widgets/custom_drawer.dart';
import 'package:my_portfolio/widgets/desc_dev_mobile.dart';
import 'package:my_portfolio/widgets/header_desktop.dart';
import 'package:my_portfolio/widgets/header_mobile.dart';
import 'package:my_portfolio/widgets/project_section.dart';
import 'package:my_portfolio/widgets/skills.dart';
import 'package:my_portfolio/widgets/skils_mobile.dart';
import 'dart:js' as js;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          key: scaffoldKey,
          endDrawer: constraints.maxWidth <= 600 ? const CustomDrawer() : null,
          backgroundColor: CustomColor.scaffoldBg,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // MAIN
                constraints.maxWidth <= 600
                    ? HeaderMobile(
                        onMenuTap: () {
                          scaffoldKey.currentState?.openEndDrawer();
                        },
                      )
                    : const HeaderDesktop(),

                constraints.maxWidth >= kMinDesktopWidth
                    ? DescriptionDev()
                    : DescDevMobile(),

                // SKILLS
                Container(
                  color: CustomColor.bgLight1,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // title
                      const Text(
                        'What I can do?',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.whitePrimary),
                      ),

                      const SizedBox(
                        height: 50,
                      ),

                      if (constraints.maxWidth >= kMedDesktopWidth)
                        const SkillsDesktop()
                      else
                        const SkilsMobile(),
                    ],
                  ),
                ),

                // PROJECTS
                const ProjectSection(),

                // FOOTER
                ContactSection(),
                const SizedBox(
                  height: 20,
                ),
                Footer()
              ],
            ),
          ));
    });
  }
}

class Footer extends StatelessWidget {
  const Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 100,
      child: Text(
          textAlign: TextAlign.center,
          "Made by Aman Obaid\nAll rights reserved"),
    );
  }
}
