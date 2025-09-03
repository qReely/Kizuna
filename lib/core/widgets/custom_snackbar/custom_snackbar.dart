import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomSnackbar {
  ThemeData theme;
  Size size;

  CustomSnackbar({required this.theme, required this.size});

  SnackBar getSnackBar(String text, {int seconds = 2}){
    return SnackBar(
      dismissDirection: DismissDirection.up,
      content: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.circleInfo,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: size.width * 0.7,
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                    style: TextStyle(color: theme.colorScheme.secondary),
                    overflow: TextOverflow.clip,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.fromLTRB(16, 0, 16, size.height - 200),
      duration: Duration(seconds: seconds),
    );
  }
}