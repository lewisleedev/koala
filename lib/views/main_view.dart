import 'package:flutter/material.dart';
import 'package:koala/views/settings_view.dart';
import 'package:koala/widgets/libstat_widget.dart';
import 'package:koala/widgets/qrcode_widget.dart';
import 'package:koala/widgets/user_status_widget.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text("Koala"),
            backgroundColor: Theme.of(context).canvasColor,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: Theme.of(context).canvasColor,
              child:  const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("QRCode",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.left),
                                      ],
                                    )),
                                QRDisplayWidget()
                              ],
                            )),
                        UserStatusWidget(),
                        LibraryRoomsWidget(),
                        SizedBox(height: 20),
                        Text("Koala: KHU's Opensource App for Library Access", style: TextStyle(fontSize: 10),),
                        SizedBox(height: 10),
                      ],
                    ),
                  )),
            ),
          )
        );
  }
}
