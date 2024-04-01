import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class DailySivu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color(0xFF1F1F1F),
      appBar: AppBar(
          backgroundColor: Color(0xFF1F1F1F),
          toolbarHeight: 97,
          title: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Tasks',
                    style: TextStyle(
                        color: Color(0xFFA3DAFF),
                        fontSize: 50,
                        fontFamily: 'GochiHand')),
                Text(formattedDate, // päivämäärä
                    style: TextStyle(
                        color: Color(0xFFA3DAFF),
                        fontSize: 20, 
                        fontFamily: 'GochiHand'))
              ],
            ),
          )),
      body: Container(
        decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage("images/tausta_ilta.png"),
      fit: BoxFit.contain, // contain 
    ),
  ),
        child: Stack(
          children: [
            // Lisää widgettejä tarvittaessa
          ],
        ),
      ),
    );
  }
}
