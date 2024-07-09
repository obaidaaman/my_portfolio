import 'package:flutter/material.dart';
import 'dart:js' as js;

import 'package:my_portfolio/constants/colors.dart';
import 'package:my_portfolio/utils/social_media_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 60),
      color: CustomColor.bgLight1,
      child: Column(
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomColor.whitePrimary),
          ),
          const SizedBox(
            height: 20,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Wrap(
              spacing: 25,
              runSpacing: 20,
              children: [
                for (int i = 0; i < socialHandles.length; i++)
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                        color: CustomColor.bgLight2,
                        borderRadius: BorderRadius.circular(5)),
                    child: ListTile(
                      onTap: () async {
                        if (socialHandles[i].socialHandleName == 'Gmail') {
                          final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: socialHandles[i].socialHandleLink,
                              queryParameters: {'subject': ''});
                          if (await canLaunchUrl(
                              Uri.parse(emailUri.toString()))) {
                            await launchUrl(Uri.parse(emailUri.toString()));
                          }
                        } else {
                          js.context.callMethod(
                              "open", [socialHandles[i].socialHandleLink]);
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: Image.asset(
                        socialHandles[i].socialHandleImage,
                        width: 26,
                      ),
                      title: Text(socialHandles[i].socialHandleName),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
