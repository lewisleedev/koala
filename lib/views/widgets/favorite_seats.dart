import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:koala/models/error_reservation.dart';
import 'package:koala/views/utils.dart';
import 'package:koala/views/widgets/card.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';

class FavoriteSeatsCard extends StatelessWidget {
  const FavoriteSeatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);

    return Observer(builder: (context) {
      bool? isUsing = false;
      if (session.status?.status == FutureStatus.fulfilled){
        isUsing = session.status?.value?.isUsing;
      }
      if (session.favoriteSeats != null) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < session.favoriteSeats!.length; i++)
                Stack(alignment: Alignment.center, children: [
                  KoalaCard(
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Text(
                            "${session.favoriteSeats![i]['seatName']}",
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          Text("${session.favoriteSeats![i]['roomName']}"),
                          FilledButton.tonalIcon(
                              onPressed: isUsing??false ? null : () async {
                                bool confirmed = await askConfirmation(
                                        context, "선호좌석 ${session.favoriteSeats![i]['roomName']}번을 예약하시겠습니까?") ??
                                    false;
                                if (confirmed) {
                                  try {
                                    await session.reserveSeat(
                                        roomCode: session.favoriteSeats![i]
                                            ['roomCode'],
                                        seatCode: session.favoriteSeats![i]
                                            ['seatCode']);
                                    if (!context.mounted) return ;
                                    showSnackbar(context, "예약되었습니다");
                                  } catch (e) {
                                    if (!context.mounted) return ;
                                    if (e is SeatReservationError) {
                                      showSnackbar(context, e.message);
                                    } else {
                                      showSnackbar(context, e.toString());
                                    }
                                  }
                                }
                              },
                              label: const Text("예약"),
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size(80, 30)),
                              icon: const Icon(Icons.chair_alt))
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                        onPressed: () async {
                          session.favoriteSeats?.removeAt(i);
                          Hive.box("settings").put("favoriteSeats", session.favoriteSeats);
                          if (!context.mounted) return ;
                          showSnackbar(context, "선호좌석이 해제되었습니다");
                        },
                        icon: Icon(
                          Icons.star,
                          color: Theme.of(context).disabledColor,
                        )),
                  )
                ]),
            ],
          ),
        );
      } else {
        return KoalaCard(
            child: Center(
          child: Column(
            children: [
              Icon(
                Icons.star_border_outlined,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "선호 좌석이 없습니다",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ));
      }
    });
  }
}
