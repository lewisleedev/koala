import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/views/reserve_seat.dart';
import 'package:koala/views/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';
import 'card.dart';
import 'error.dart';

class LibraryRoomListCard extends StatelessWidget {
  const LibraryRoomListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    return Observer(builder: (_) {
      if (session.libraryStatus?.status == FutureStatus.pending) {
        return const KoalaCard(
            height: 36, child: Center(child: CircularProgressIndicator()));
      } else if (session.libraryStatus?.status == FutureStatus.rejected) {
        return KoalaCard(
            height: 40,
            child: ErrorBox(errMsg: session.libraryStatus!.error.toString()));
      } else if (session.libraryStatus?.status == FutureStatus.fulfilled) {
        return Column(
          children: [
            for (var roomData in session.libraryStatus?.result)
              LibraryRoomCard(roomData: roomData)
          ], //Here
        );
      }
      return Container();
    });
  }
}

class LibraryRoomCard extends StatelessWidget {
  late Map<String, dynamic> roomData;

  LibraryRoomCard({super.key, required this.roomData});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (roomData['isAvailable']){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {return SeatReservationView(roomData: roomData);}));
        } else {
          showSnackbar(context, "이용가능시간이 아닙니다");
        }
      },
      child: KoalaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${roomData['name']}",
                  style: const TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14),
                    Text("${roomData['inUse']}/${roomData['available']}")
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.primary,
              value: roomData['inUse'] / roomData['available'],
            ),
            const SizedBox(
              height: 12,
            ),
            Text("이용가능시간: ${roomData['usageTimeString']}"),
          ],
        ),
      ),
    );
  }
}
