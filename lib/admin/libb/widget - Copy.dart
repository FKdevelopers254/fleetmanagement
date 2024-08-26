import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
class AppBarr extends StatefulWidget {

  final String foodtitle;
  const AppBarr({super.key, required this.foodtitle});

  @override
  State<AppBarr> createState() => _AppBarrState();
}

class _AppBarrState extends State<AppBarr> {
  static const Color myAppBarColor = Colors.yellow; // Blue color
  static const Color myIconColor = Colors.orange; // Blue color
  static const Color myBorderColor = Colors.orange;
  static const colorizeColors = [
    Colors.white,
    myAppBarColor,
    Colors.white,
    Colors.white,
  ];

  static final colorizeTextStyle = GoogleFonts.merriweather(

      fontSize: 22.0,
      fontWeight: FontWeight.w700

  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[

        Container(
          height: 35.0,

          decoration: const BoxDecoration(
              color:  myAppBarColor,
              //   color: Color(0xFFFD7465),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5.0,),
                bottomLeft: Radius.circular(75.0,),
                topLeft: Radius.circular(75.0,),
                topRight: Radius.circular(75.0,),
              )
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 5,),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  widget.foodtitle,
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                ),


              ],

              isRepeatingAnimation: true,

            ),



            const SizedBox(width: 5,),
          ],
        ),
      ],
    );
  }
}

class LeadingAppBar extends StatefulWidget {
  const LeadingAppBar({super.key});

  @override
  State<LeadingAppBar> createState() => _LeadingAppBarState();
}

class _LeadingAppBarState extends State<LeadingAppBar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration:  const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(75.0,),
                bottomLeft: Radius.circular(5.0,),
                topLeft: Radius.circular(5.0,),
                topRight: Radius.circular(75.0,),
              ),
              color:  _AppBarrState.myAppBarColor,
          ),
          child: const Icon(Icons.arrow_back,color: Colors.white,),

        ),
      ),
    );
  }
}

class ActionsWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const ActionsWidget({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(75.0),
            topLeft: Radius.circular(75.0),
            topRight: Radius.circular(5.0),
          ),
          color:  _AppBarrState.myAppBarColor,
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 34),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class SubmitWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const SubmitWidget({Key? key, required this.onPressed, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:  _AppBarrState.myAppBarColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GestureDetector(
            onTap: onPressed,
            child: Text(title, style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),)),
      ),
    );
  }
}