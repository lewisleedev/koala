import 'dart:async';
import 'package:flutter/material.dart';
import 'package:koala/views/seat_reserve_view.dart';
import '../services/library_status.dart';

class LibraryRoomsWidget extends StatefulWidget {
  const LibraryRoomsWidget({super.key});

  @override
  _LibraryRoomsWidgetState createState() => _LibraryRoomsWidgetState();
}

class _LibraryRoomsWidgetState extends State<LibraryRoomsWidget> {
  Future<List<dynamic>>? _futureRooms;

  @override
  void initState() {
    super.initState();
    _futureRooms = getLibraryStatus();
    _refreshDataPeriodically();
  }

  void _refreshDataPeriodically() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {
          _futureRooms = getLibraryStatus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureRooms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Container(
              width: double.infinity, // Adjust based on your UI needs
              height: 200,
              padding: const EdgeInsets.all(8),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
              child: Container(
                width: double.infinity, // Adjust based on your UI needs
                height: 200,
                padding: const EdgeInsets.all(8),
                child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Something went wrong:${snapshot.error}"),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _refreshDataPeriodically, child: const Text("Refresh"))
                  ],
                )),
              ));
        } else if (snapshot.hasData) {
          List<dynamic> rooms = snapshot.data!;
          return SizedBox(
            height: 200, // Adjust based on your UI needs
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                var room = rooms[index];
                return Card(
                  child: Container(
                    width: 300, // Adjust based on your UI needs
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(room['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Text('Available: ${room['available']}'),
                        Text('In Use: ${room['inUse']}'),
                        Text('Day Off: ${room['dayOff'] ?? "No"}'),
                        OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SeatReserveWidget(room: room)
                              ));
                            },
                            child: const Text("Reserve a seat"))
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No data'));
        }
      },
    );
  }
}
