import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scatter_brain/constants/colors.dart'; 

class DailySivu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Tausta,
      appBar: AppBar(
          backgroundColor: Tausta,
          toolbarHeight: 97,
          title: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Tasks',
                    style: TextStyle(
                        color: Sininen,
                        fontSize: 50,
                        fontFamily: 'GochiHand')),
                Text(formattedDate, // päivämäärä
                    style: TextStyle(
                        color: Sininen,
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
