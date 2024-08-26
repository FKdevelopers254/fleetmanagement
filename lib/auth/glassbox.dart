import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final child;
  const GlassBox({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 65,
        padding: EdgeInsets.all(2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20,sigmaY: 20),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
    );
  }
}



class GlassBoxx extends StatelessWidget {
  final child;
  const GlassBoxx({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
    //  height: 300,
    //  padding: EdgeInsets.all(2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3,sigmaY: 3),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
    );
  }
}



class GlassBoxxx extends StatelessWidget {
  final child;
  const GlassBoxxx({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      //  height: 300,
      //  padding: EdgeInsets.all(2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20,sigmaY: 20),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
    );
  }
}

