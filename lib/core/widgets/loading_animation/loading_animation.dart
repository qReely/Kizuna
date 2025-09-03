import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingAnimation extends StatelessWidget {
  final String? text;
  const LoadingAnimation({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 110),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/book_loader.json", width: 200, frameRate: FrameRate(30), backgroundLoading: true,),
            Container(
              height: 30,
              alignment: Alignment.center,
              child: Text(text ?? "Loading", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            )
          ],
        )
      ),
    );
  }
}
