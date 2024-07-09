import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';
import 'package:my_portfolio/utils/project_utils.dart';
import 'dart:js' as js;

class ProjectCardWidget extends StatelessWidget {
  const ProjectCardWidget({
    super.key,
    required this.project,
  });
  final ProjectUtils project;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 290,
      width: 260,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: CustomColor.bgLight2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            project.image,
            height: 140,
            width: 260,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 15, 12, 10),
            child: Text(
              project.title,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: CustomColor.whitePrimary),
            ),
          ),

          //subtitle
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              project.subtitle,
              style: TextStyle(color: CustomColor.whiteSecondary, fontSize: 10),
            ),
          ),
          const Spacer(),
          Container(
            color: CustomColor.bgLight1,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Available on:',
                  style: TextStyle(
                      color: CustomColor.yellowSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                if (project.IosLink != null)
                  InkWell(
                    onTap: () {
                      js.context.callMethod("open", [project.IosLink]);
                    },
                    child: Image.asset(
                      'assets/ios_icon.png',
                      width: 16,
                    ),
                  ),
                project.androidLink != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () {
                            js.context
                                .callMethod("open", [project.androidLink]);
                          },
                          child: Image.asset(
                            'assets/android_icon.png',
                            width: 17,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: InkWell(
                          onTap: () {
                            js.context.callMethod("open", [project.githubLink]);
                          },
                          child: Image.asset(
                            'assets/github.png',
                            width: 17,
                          ),
                        ),
                      ),
                if (project.webLink != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () {
                        js.context.callMethod("open", [project.webLink]);
                      },
                      child: Image.asset(
                        'assets/web_icon.png',
                        width: 17,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
