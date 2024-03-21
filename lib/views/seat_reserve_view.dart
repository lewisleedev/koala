
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/seats_widget.dart';

class SeatReserveWidget extends StatelessWidget {
  var room;

  SeatReserveWidget({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Reserve seat: ${room['name']}"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Expanded(
                child: Container(
                    width: double.infinity,
                    child: LayoutBuilder(builder:
                        (BuildContext context,
                        BoxConstraints constraints) {
                      return SeatsCanvas(
                        roomCode: room['code'],
                        backgroundImg: room['backgroundImg'],
                        roomName: room['name'],
                      );
                    },
                    )                ),
              ),
          SizedBox(height: 10)
          ]
      ),
    );
  }
}