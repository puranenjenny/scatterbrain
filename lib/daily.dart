import 'package:flutter/material.dart';

class DailySivu extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F1F1F),
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 25),
          child: Text('Daily Tasks', style: TextStyle(color: Color(0xFFA3DAFF), fontSize: 50, fontFamily: 'GochiHand')),
        )),
      body: Container(
        decoration: BoxDecoration( 
        image: DecorationImage(
          image: AssetImage("images/tausta_ilta.png"), // taustakuva
          fit: BoxFit.cover, // täyttää koko ruudun
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

