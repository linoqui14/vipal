

import 'package:flutter/material.dart';

import '../tools/my_colors.dart';

class CustomTextButton extends StatelessWidget{
  const CustomTextButton(
      {
        Key? key,
        required this.onPressed,
        this.text="Text Here",
        this.rTR=10,this.rTl=10,
        this.rBR=10,this.rBL=10,
        this.color=MyColors.skyBlueDead,
        this.width = 100
      }) : super(key: key);

  final Function onPressed;
  final String text;
  final double rTl,rTR,rBL,rBR;
  final Color color;
  final double width;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
        onPressed: (){

          onPressed.call();
        },
        child: Container(
            alignment: Alignment.center,
            width: width,
            child: Text(text,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(rBL),
                    bottomRight:  Radius.circular(rBR),
                    topLeft: Radius.circular(rTl),
                    topRight:  Radius.circular(rTR),

                  ),

                )
            )
        )
    );
  }
}
