import 'dart:async';
import 'package:flutter/material.dart';
import 'package:koala/views/seat_reserve_view.dart';
import '../services/library_status.dart';
import '../services/utils.dart';

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
    _futureRooms = libraryStatusHandler();
    _refreshDataPeriodically();
  }

  void _refreshDataPeriodically() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {
          _futureRooms = libraryStatusHandler();
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
                padding: const EdgeInsets.all(12),
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
                bool isOpen = isRoomOpen(room['fromHour'], room['untilHour']);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                                avatar: const Icon(Icons.chair)
                                ,label: Text("${room['available']}")),
                            SizedBox(width: 8),
                            Chip(
                                avatar: const Icon(Icons.person)
                                ,label: Text("${room['inUse']}")),
                          ],
                        ),
                        OutlinedButton(
                            onPressed: isOpen ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SeatReserveWidget(room: room)
                              ));
                            } : null,
                            child: isOpen ? const Text("Reserve a seat") : const Text("Closed")
                        )
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
