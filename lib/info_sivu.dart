import 'package:flutter/material.dart';
import 'package:scatter_brain/constants/colors.dart';

class InfoSivu extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
        backgroundColor: Tausta,
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
          child: Text('Info', style: TextStyle(color:Sininen, fontSize: 50, fontFamily: 'GochiHand')),
        )),
      body: Container(
        decoration: BoxDecoration( 
        image: DecorationImage(
          image: AssetImage("images/tausta_info.png"), // taustakuva
          fit: BoxFit.fill, // fill näyttää koko kuvan
        ),
      ),
        child: Stack(
        children: [
          
         /*  Positioned( //napin sijainti
            top: 0, // ylhäältä 0 pikseliä
            right: 40, // oikealta 30 pikseliä
/*             child: FloatingActionButton( 
              onPressed: Null,
              child: Image.asset('images/btn_add.png'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ), */
          ), */
        ],
            ),
      ),
    );
  }
}