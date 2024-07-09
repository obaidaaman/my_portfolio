import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';
import 'package:my_portfolio/constants/nav_items.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: CustomColor.scaffoldBg,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close))),
            Expanded(
              child: ListView.builder(
                  itemCount: navTitles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      onTap: () {},
                      titleTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: CustomColor.whitePrimary),
                      leading: Icon(navIcons[index]),
                      title: Text(navTitles[index]),
                    );
                  }),
            )
          ],
        ));
  }
}
