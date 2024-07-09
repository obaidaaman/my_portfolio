import 'package:flutter/material.dart';
import 'package:my_portfolio/constants/colors.dart';
import 'package:my_portfolio/widgets/site_logo.dart';

class HeaderMobile extends StatelessWidget {
  const HeaderMobile({super.key, this.onLogoTap, this.onMenuTap});
  final VoidCallback? onLogoTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.blueGrey,
          gradient: LinearGradient(
              colors: [Colors.transparent, CustomColor.bgLight1]),
          borderRadius: BorderRadius.circular(80)),
      margin: EdgeInsets.fromLTRB(40, 5, 20, 5),
      child: Row(
        children: [
          SiteLogo(
            onTap: onLogoTap,
          ),
          Spacer(),
          IconButton(onPressed: onMenuTap, icon: Icon(Icons.menu)),
          SizedBox(
            width: 15,
          )
        ],
      ),
    );
  }
}
